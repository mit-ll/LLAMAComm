function [ Ldb, sigmadb, Fext ] = getPathloss(txnode, rxnode, env)

% function 'getPathloss'
% Get path loss statistics for link between two nodes, 
% Returns median pathloss, and standard deviation between terminals
% also returns external noise figure for link
%
% USAGE: [Ldb, sigmadb, Fext] = getPathloss(txnode, rxnode, env)
%
% Input arguments:
%  txnode    (node object) Transmitter node
%  rxnode    (node object) Receiver node
%  env       (environment object) Environment object
%
% Output arguments:
%  Ldb       (scalar) Median pathloss (db)
%  sigmadb   (scalar) Pathloss standard deviation (db)
%  Fext      (scalar) External noise figure (db)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Extract building parameters from tx and rx nodes
txbuilding = txnode.building;
rxbuilding = rxnode.building;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract parameters used by propagation models

fmhz = rxnode.fc/1e6 ;        % (MHz) Center frequency of receiver
htx = txnode.location(3);     % tx height above mean ground level
hrx = rxnode.location(3);     % rx height above mean ground level
dm  = sqrt( (rxnode.location(1) - txnode.location(1))^2 + ...
            (rxnode.location(2) - txnode.location(2))^2 ); % ground range, m
if dm==0
  error('getPathloss doesn''t work on co-located nodes');
end

pol = txnode.polarize(1, :);   % assumes all antennas have same pol
if strcmp(pol, 'h') 
  tpol = 'h'; 
else 
  tpol = 'v';
end

hhn = max(htx, hrx); % high node height
hln = min(htx, hrx); % low node height 
hrm = env.building.roofHeight; % avg. roof height, m
los_dist = env.los_dist;
if ~strcmp(txbuilding.extwallmat, 'none');  % tx is indoors
  ddtx = txbuilding.intdist;       % shortest in-building path length
  niwallstx = txbuilding.intwalls; % number of interior walls in path
else ddtx = 0;
end
if ~strcmp(rxbuilding.extwallmat, 'none')   % rx is indoors
  ddrx = rxbuilding.intdist;     % shortest in-building path length
  niwallsrx = rxbuilding.intwalls; % number of interior walls in path
else ddrx = 0; % Rx is outdoors
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% urban propagation model with both nodes outdoors

if strncmp(env.scenarioType, 'urban', 5) && ddrx==0 && ddtx==0 

  deltran = 10; % transition height from below to above roof

  if hhn<hrm  % both antennas below roof height     
    if dm<=los_dist;    % LOS
      Ldb = mean2pathflat(dm/1000, htx, hrx, fmhz, tpol, 15, 0.005);
      sigmadb = 0;      
    else % NLOS 
      Ldb = cost231(dm/1000, fmhz, hln, hhn, hrm, [], [], [], 1);
      sigmadb = okumura_sigma(fmhz, 'U');
    end

  elseif hhn<=(hrm+deltran)  % upper antenna near roof height    
    if dm<=los_dist;    % LOS
      Ldb = mean2pathflat(dm/1000, htx, hrx, fmhz, tpol, 15, 0.005);
      sigmadb = 0;      

    elseif dm<=5000 % NLOS
      Lbelow = cost231(dm/1000, fmhz, hln, hhn, hrm, [], [], [], 1);
      Labove = groundtotower(dm, fmhz, hln, hhn, hrm, tpol, 'U', los_dist);
      Ldb = ( (hhn-hrm)*Labove + ...
              (hrm+deltran-hhn)*Lbelow )/deltran;
      sigmadb = okumura_sigma(fmhz, 'U');

    else
      Ldb = groundtotower(dm, fmhz, hln, hhn, hrm, tpol, 'U', los_dist);
      sigmadb = okumura_sigma(fmhz, 'U');

    end

  elseif hhn>(hrm+deltran) && hln<hrm && hhn<=200 
    % one antenna below roof height, other on roof or tower
    [ Ldb sigmadb ] = groundtotower(dm, fmhz, hln, hhn, hrm, tpol, 'U', los_dist);

  elseif hln<(hrm) && hhn>200 
    % one antenna below roof height, other airborne or on mountain
    dmax = 20000;  % maximum range for gound-tower models, m
    hmax = 200;    % maximum height for ground-tower models, m
    tantheta = (hhn-hln)/dm; % tangent of prop path elevation angle
    hpn = dmax*tantheta;     % pseudo-node height when range-limited
    if hpn<=hmax; 
      dpn=dmax;  % pseudo-node range
    else         % pseudo-node is height-limited 
      hpn=hmax;  
      dpn=hmax/tantheta; % pseudo-node range when height-limited
    end
    Llos = los(sqrt((hhn-hln)^2 + dm^2 ), fmhz); % LOS loss
    [ Lobs sigmadb ] = groundtotower(dpn, fmhz, hln, hpn, hrm, tpol, 'U', los_dist);
    Lex = Lobs - los( sqrt((hpn-hln)^2 + dpn^2 ), fmhz); % excess loss
    Ldb = Llos + Lex;

  elseif hln>=(hrm) && hhn<=1000 %  both antennas above roof height
    if dm < 1000
      [ Ldb sigmadb ] = cabot(dm, fmhz, hln, hhn, 30, tpol);
    else
      [ Ldb sigmadb ] = longley_rice(dm/1000, fmhz, [ hhn hln ], 30, tpol);
    end
  elseif hln>=(hrm) && hhn>1000 %  both antennas above roof height
                                % higher antenna airborne or on mountain
                                % use hybird Longley-Rice with LOS
    dmax = 2e6;   % maximum range for LR model, m
    hmax = 1000;  % maximum height used here for LR model, m
    tantheta = (hhn-hln)/dm; % tangent of prop path elevation angel
    hpn = dmax*tantheta;     % pseudo-node height when range-limited
    if hpn<=hmax; 
      dpn=dmax;  % pseudo-node range
    else         % pseudo-node is height-limited 
      hpn=hmax;  
      dpn=hmax/tantheta; % pseuod-node range when height-limited
    end
    Llos = los(sqrt((hhn-hln)^2 + dm^2 ), fmhz); % LOS loss
    if dpn<10
      Lobs = los(sqrt(dpn^2+(hpn-hln)^2), fmhz);
      sigmadb = 0;
    elseif dpn<1000
      [ Lobs sigmadb ] = cabot(dpn, fmhz, hln, hpn, 30, tpol);
    else
      [ Lobs sigmadb ] = longley_rice(dpn/1000, fmhz, [hpn hln ], 30, tpol);
    end
    Lex = Lobs - los( sqrt((hpn-hln)^2 + dpn^2), fmhz); % excess loss
    Ldb = Llos + Lex;

  end % end antenna height selection

end % end urban, all-outdoor

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % urban propagation model with only one node indoors 

  if strncmp(env.scenarioType, 'urban', 5) && xor(ddtx>0, ddrx>0)

    % set indoor and outdoor node parameters
    if ddtx>0 % Tx is indoors, Rx is not
      dd = ddtx; % indoor node to penetration point distance, m
      hind = txnode.location(3);  % indoor antenna height, m
      hout = rxnode.location(3);  % outdoor antenna height, m
      intwalls = niwallstx;
      extbldgangle = txbuilding.extbldgangle;
    else % Rx is indoors, Tx is not
      dd = ddrx; % indoor node to penetration point distance, m
      hind = rxnode.location(3);  % indoor antenna height, m
      hout = txnode.location(3);  % outdoor antenna height, m
      intwalls = niwallsrx;
      extbldgangle = rxbuilding.extbldgangle;
    end

    deltran = 10;  % below to above roof transition region

    if dm<=los_dist; % 1 node outside building, building is LOS to exterior node
      theta = pi/180 * extbldgangle; % 2D prop-path angle with wall
      a1 = -2*dd*cos(theta+pi/2);
      a0 = dd^2 - dm^2;
      ds = (-a1+sqrt(a1^2-4*a0))/2; % penetration point to exterior node path length, m 
      do = ds*sin(theta); % orthogonal (to building) exterior-node path component
      dp = ds*cos(theta); % parallel (to building) exterior-node path component
      Ldb = into_bldg_los(do, dp, dd, fmhz, hout, hind, intwalls);
      sigmadb = 4;

    else % 1 node outside building, building is NLOS to it, i.e., 
         % face of building at indoor node level is NLOS to outdoor antenna
      Lbldg = into_bldg(dd, fmhz, 2, intwalls); % building penetration loss
      sigbldg = 4; % Lbldg standard deviation
      
      % outdoor path loss
      href = max(2, hind); % outdoor reference point height, m
      if hout<(hrm); % both antennas below roof height      
        Lout = cost231(dm/1000, fmhz, min(hout, href), max(hout, href), ...
                       hrm, [], [], [], 1);
        sigout = okumura_sigma(fmhz, 'U');
      elseif hout<hrm+deltran && dm<=5000 % transition region
        Lbelow = cost231(dm/1000, fmhz, min(hout, href), max(hout, href), ...
                         hrm, [], [], [], 1);
        Labove = groundtotower(dm, fmhz, href, hout, hrm, tpol, 'U', los_dist);
        Lout = ( (hout-hrm)*Labove + ...
                 (hrm+deltran-hout)*Lbelow )/deltran;
        sigout = okumura_sigma(fmhz, 'U');
      elseif hout<200 % outdoor antenna is well above roof height
        [ Lout sigout ] = groundtotower(dm, fmhz, href, hout, hrm, tpol, 'U', los_dist);
      else % outdoor antenna airborne or on mountain
        dmax = 20000;  % maximum range for gound-tower models, m
        hmax = 200;    % maximum height for ground-tower models, m
        tantheta = (hhn-href)/dm; % tangent of prop path elevation angel
        hpn = dmax*tantheta;     % pseudo-node height when range-limited
        if hpn<=hmax; 
          dpn=dmax;  % pseudo-node range
        else         % pseudo-node is height-limited 
          hpn=hmax;  
          dpn=hmax/tantheta; % pseuod-node range when height-limited
        end
        Llos = los(sqrt((hout-href)^2 + dm^2 ), fmhz); % LOS loss
        [ Lobs sigout ] = groundtotower(dpn, fmhz, href, hpn, hrm, tpol, 'U', los_dist);
        Lex = Lobs - los( sqrt((hpn-href)^2+dpn^2), fmhz);
        Lout = Llos + Lex;
      end % end outdoor antenna high decision

        % combine building and path loss
        Ldb = Lbldg + Lout;
        sigmadb = sqrt( sigbldg^2 + sigout^2 );

    end % LOS vs NLOS decision

  end % urban, one indoor node

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % urban propagation model with both nodes indoors 

  if strncmp(env.scenarioType, 'urban', 5) && ddtx>0 && ddrx>0

    if dm<=30; % same building

      [ Ldb sigmadb ] = indoor_concrete(dm, fmhz, htx, hrx);

    else % nodes in different buildings

      Lbldgtx = into_bldg(ddtx, fmhz, 2, niwallstx); % building penetration loss
      sigbldgtx = 4; % Lbldg standard deviation

      Lbldgrx = into_bldg(ddrx, fmhz, 2, niwallsrx); % building penetration loss
      sigbldgrx = 4; % Lbldg standard deviation
      
      % outdoor path loss
      htxref = max(htx, 2); % Tx outdoor reference point height, m
      hrxref = max(hrx, 2); % Rx outdoor reference point height, m
      Lout = cost231(dm/1000, fmhz, htxref, hrxref, hrm, [], [], [], 1);
      sigout = okumura_sigma(fmhz, 'U');

      % combine building and path loss
      Ldb = Lbldgtx + Lbldgrx + Lout;
      sigmadb = sqrt( sigbldgtx^2 + sigbldgrx^2 + sigout^2 );

    end % distance decision

  end % urban, both indoor nodes

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % suburban propagation model with both nodes outdoors

  if strncmp(env.scenarioType, 'suburban', 5) && ddtx ==0 && ddrx==0  % suburban, all outdoors

    deltran = 10; % below roof to above roof transition region 

    if hhn<(hrm)  % both antennas below roof height    
      if dm<=los_dist;    % LOS
        Ldb = mean2pathflat(dm/1000, htx, hrx, fmhz, tpol, 15, 0.005);
        sigmadb = 0;      
      else % NLOS 
        Ldb = cost231(dm/1000, fmhz, hln, hhn, hrm, [], [], [], 0);
        sigmadb = okumura_sigma(fmhz, 'S');
      end

    elseif hhn<(hrm+deltran) && dm<5000 % transition region
      Lbelow = cost231(dm/1000, fmhz, hln, hhn, hrm, [], [], [], 0);
      Labove = groundtotower(dm, fmhz, hln, hhn, hrm, tpol, 'S', los_dist);
      Ldb    = ( (hhn-hrm)*Labove + (hrm+deltran-hhn)*Lbelow)/deltran;
      sigmadb = okumura_sigma(fmhz, 'S');

    elseif  hln<(hrm) && hhn<=200 
      % one antenna below roof height, other on roof or tower
      [ Ldb sigmadb ] = groundtotower(dm, fmhz, hln, hhn, hrm, tpol, 'S', los_dist);

    elseif  hln<(hrm) && hhn>200 
      % one antenna below roof height, other airborne or on mountain
      dmax = 20000;  % maximum range for gound-tower models, m
      hmax = 200;    % maximum height for ground-tower models, m
      tantheta = (hhn-hln)/dm; % tangent of prop path elevation angel
      hpn = dmax*tantheta;     % pseudo-node height when range-limited
      if hpn<=hmax; 
        dpn=dmax;  % pseudo-node range
      else         % pseudo-node is height-limited 
        hpn=hmax;  
        dpn=hmax/tantheta; % pseudo-node range when height-limited
      end
      Llos = los(sqrt((hhn-hln)^2 + dm^2 ), fmhz); % LOS loss
      [ Lobs sigmadb ] = groundtotower(dpn, fmhz, hln, hpn, hrm, tpol, 'S', los_dist);
      Lex = Lobs - los( sqrt((hpn-hln)^2 + dpn^2 ), fmhz); % excess loss
      Ldb = Llos + Lex;

    elseif hln>=(hrm) && hhn<=1000 %  antennas above roof height
      if dm < 1000
        [ Ldb sigmadb ] = cabot(dm, fmhz, hln, hhn, 30, tpol);
      else
        [ Ldb sigmadb ] = longley_rice(dm/1000, fmhz, [ hhn hln ], 30, tpol);
      end

    elseif hln>=(hrm) && hhn>1000 %  both antennas above roof height
                                  % higher antenna airborne or on mountain
                                  % use hybird Longly-Rice with LOS
      dmax = 2e6;   % maximum range for LR model, m
      hmax = 1000;  % maximum height used here for LR model, m
      tantheta = (hhn-hln)/dm; % tangent of prop path elevation angel
      hpn = dmax*tantheta;     % pseudo-node height when range-limited
      if hpn<=hmax; 
        dpn=dmax;  % pseudo-node range
      else         % pseudo-node is height-limited 
        hpn=hmax;  
        dpn=hmax/tantheta; % pseuod-node range when height-limited
      end
      Llos = los(sqrt((hhn-hln)^2 + dm^2 ), fmhz); % LOS loss
      if dpn<10
        Lobs = los(sqrt(dpn^2+(hpn-hln)^2), fmhz);
        sigmadb = 0;
      elseif dpn<1000
        [ Lobs sigmadb ] = cabot(dpn, fmhz, hln, hpn, 30, tpol);
      else
        [ Lobs sigmadb ] = longley_rice(dpn/1000, fmhz, [hpn hln ], 30, tpol);
      end
      Lex = Lobs - los( sqrt((hpn-hln)^2 + dpn^2), fmhz); % excess loss
      Ldb = Llos + Lex;

    end % end antenna height selection

  end % end suburban, outdoor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % suburban propagation model with one node indoors and one outdoors

    if strncmp(env.scenarioType, 'suburban', 5) && xor(ddtx>0, ddrx>0)

      % set indoor and outdoor node parameters
      if ddtx>0 % Tx is indoors, Rx is not
        dd = ddtx; % indoor node to penetration point distance, m
        hind = txnode.location(3);  % indoor antenna height, m
        hout = rxnode.location(3);  % outdoor antenna height, m
        intwalls = niwallstx;
        extbldgangle = txbuilding.extbldgangle;
      else % Rx is indoors, Tx is not
        dd = ddrx; % indoor node to penetration point distance, m
        hind = rxnode.location(3);  % indoor antenna height, m
        hout = txnode.location(3);  % outdoor antenna height, m
        intwalls = niwallsrx;
        extbldgangle = rxbuilding.extbldgangle;
      end

      if dm<=los_dist; % 1 node outside building, building is LOS to outdoor node
        theta = pi/180 * extbldgangle; % 2D prop-path angle with wall
        a1 = -2*dd*cos(theta+pi/2);
        a0 = dd^2 - dm^2;
        ds = (-a1+sqrt(a1^2-4*a0))/2; % pp to exterior node range
        do = ds*sin(theta);
        dp = ds*cos(theta);
        Ldb = into_bldg_los(do, dp, dd, fmhz, hout, hind, intwalls);
        sigmadb = 4;

      else % 1 node outside building, building is NLOS to it, i.e., 
           % face of building at indoor node level is NLOS to outdoor antenna

        % building loss:
        Lbldg = into_bldg(dd, fmhz, 2, intwalls); % building penetration loss
        sigbldg = 4; % Lbldg standard deviation
        
        % outdoor path loss
        deltran = 10; % below-roof to above-roof transition region
        href = max(hind, 2); % outdoor reference point height, m
        if hout<(hrm); % both antennas below roof height      
          Lout = cost231(dm/1000, fmhz, min(hout, href), max(hout, href), ...
                         hrm, [], [], [], 0);
          sigout = okumura_sigma(fmhz, 'S');
        elseif hout<(hrm+deltran) && dm<5000
          Lbelow = cost231(dm/1000, fmhz, min(hout, href), max(hout, href), ...
                           hrm, [], [], [], 0);
          Labove = groundtotower(dm, fmhz, href, hout, hrm, tpol, 'S', los_dist);
          Lout = ( (hout-hrm)*Labove + (hrm+deltran-hout)*Lbelow )/deltran;
          sigout = okumura_sigma(fmhz, 'S');
        elseif hout<200 % outdoor antenna is above roof height
          [ Lout sigout ] = groundtotower(dm, fmhz, href, hout, hrm, tpol, 'S', los_dist);
        else % outdoor antenna airborne or on mountain
          dmax = 20000;  % maximum range for gound-tower models, m
          hmax = 200;    % maximum height for ground-tower models, m
          tantheta = (hhn-href)/dm; % tangent of prop path elevation angel
          hpn = dmax*tantheta;     % pseudo-node height when range-limited
          if hpn<=hmax; 
            dpn=dmax;  % pseudo-node range
          else         % pseudo-node is height-limited 
            hpn=hmax;  
            dpn=hmax/tantheta; % pseuod-node range when height-limited
          end
          Llos = los(sqrt((hout-href)^2 + dm^2 ), fmhz); % LOS loss
          [ Lobs sigout ] = groundtotower(dpn, fmhz, href, hpn, hrm, tpol, 'S', los_dist);
          Lex = Lobs - los(sqrt((hpn-href)^2+dpn^2), fmhz); % excess loss
          Lout = Llos + Lex;

        end % end of outdoor antenna height decision

          % combine building and path loss
          Ldb = Lbldg + Lout;
          sigmadb = sqrt( sigbldg^2 + sigout^2 );

      end % LOS vs NLOS decision

    end % suburban, one indoor node, one outdoor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % suburban propagation model with both nodes indoors

    if strncmp(env.scenarioType, 'suburban', 5) && ddtx>0 && ddrx>0

      if dm<=10; % same building

        [ Ldb sigmadb ] = indoor_concrete(dm, fmhz, htx, hrx);
        
      else % nodes in different buildings

        Lbldgtx = into_bldg(ddtx, fmhz, 2, niwallstx); % building penetration loss
        sigbldgtx = 4; % Lbldg standard deviation

        Lbldgrx = into_bldg(ddrx, fmhz, 2, niwallsrx); % building penetration loss
        sigbldgrx = 4; % Lbldg standard deviation
        
        % outdoor path loss
        htxref = max(htx, 2); % Tx outdoor reference point height, m
        hrxref = max(hrx, 2); % Rx outdoor reference point height, m
        Lout = cost231(dm/1000, fmhz, htxref, hrxref, hrm, [], [], [], 0);
        sigout = okumura_sigma(fmhz, 'S');

        % combine building and path loss
        Ldb = Lbldgtx + Lbldgrx + Lout;
        sigmadb = sqrt( sigbldgtx^2 + sigbldgrx^2 + sigout^2 );

      end % distance decision

    end % suburban, both indoors

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rural propagation model with both nodes outdoors

    if strncmp(env.scenarioType, 'rural', 5) && ddtx==0 && ddrx == 0% rural, all outdoors
     
      if dm<10 % currently no good model in this range
        rm = sqrt( dm^2 + (hhn-hln)^2 );
        Ldb = los(rm, fmhz);
        sigmadb = 0;

      elseif dm<1000
        [ Ldb sigmadb ] = cabot(dm, fmhz, hln, hhn, 90, tpol);

      elseif hhn<=1000  % everything is Longly-Rice
        [ Ldb sigmadb ] = longley_rice(dm/1000, fmhz, [ hhn hln ], 90, tpol);

      elseif hhn>1000 % one antenna is airborne or on mountain 
                      % use hybird Longly-Rice with LOS
        dmax = 2e6;   % maximum range for LR model, m
        hmax = 1000;  % maximum height used here for LR model, m
        tantheta = (hhn-hln)/dm; % tangent of prop path elevation angel
        hpn = dmax*tantheta;     % pseudo-node height when range-limited
        if hpn<=hmax; 
          dpn=dmax;  % pseudo-node range
        else         % pseudo-node is height-limited 
          hpn=hmax;  
          dpn=hmax/tantheta; % pseuod-node range when height-limited
        end
        Llos = los(sqrt((hhn-hln)^2 + dm^2 ), fmhz); % LOS loss
        if dpn<10
          Lobs = los(sqrt(dpn^2+(hpn-hln)^2), fmhz);
          sigmadb = 0;
        elseif dpn<1000
          [ Lobs sigmadb ] = cabot(dpn, fmhz, hln, hpn, 90, tpol);
        else
          [ Lobs sigmadb ] = longley_rice(dpn/1000, fmhz, [ hpn hln ], 90, tpol);
        end
        Lex = Lobs - los( sqrt((hpn-hln)^2 + dpn^2 ), fmhz); % excess loss
        Ldb = Llos + Lex;

      else
        error('parameters outside range, function getPathloss');

      end % end antenna height selection

    end % end rural, two outdoor nodes

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % rural propagation model with one node indoors and one outdoors

      if strncmp(env.scenarioType, 'rural', 5) && xor(ddtx>0, ddrx>0) 

        % set indoor and outdoor node parameters
        if ddtx>0 % Tx is indoors, Rx is not
          dd = ddtx; % indoor node to penetration point distance, m
          hind = txnode.location(3);  % indoor antenna height, m
          hout = rxnode.location(3);  % outdoor antenna height, m
          intwalls = niwallstx;
          extbldgangle = txbuilding.extbldgangle;
        else % Rx is indoors, Tx is not
          dd = ddrx; % indoor node to penetration point distance, m
          hind = rxnode.location(3);  % indoor antenna height, m
          hout = txnode.location(3);  % outdoor antenna height, m
          intwalls = niwallsrx;
          extbldgangle = rxbuilding.extbldgangle;
        end

        if dm < 1000; %  treat building as LOS to outside node

          % one exterior wall (this is a small house)
          theta = pi/180 * extbldgangle; % 2D prop-path angle with wall
          a1 = -2*dd*cos(theta+pi/2);
          a0 = dd^2 - dm^2;
          ds = (-a1+sqrt(a1^2-4*a0))/2; % pp to exterior node range
          do = ds*sin(theta);
          dp = ds*cos(theta);
          Ldb1 = into_bldg_los(do, dp, dd, fmhz, hout, hind, intwalls);

          % the other exterior wall (this is still a small house)
          theta2 = pi/180 * (90-extbldgangle); % 2D prop-path angle with wall
          a1 = -2*dd*cos(theta2+pi/2);
          a0 = dd^2 - dm^2;
          ds = (-a1+sqrt(a1^2-4*a0))/2; % pp to exterior node range
          do = ds*sin(theta2);
          dp = ds*cos(theta2);
          Ldb2 = into_bldg_los(do, dp, dd, fmhz, hout, hind, intwalls);

          Ldb = -db10( undb10(-Ldb1) + undb10(-Ldb2) );
          sigmadb = 4;

          if dm>10 % lose simple LOS propagation from wall to outdoor Rx
            
            [ Lout sigout ] = cabot(dm, fmhz, 2, hout, 90, tpol);
            rm = sqrt( dm^2 + (htx-hrx)^2 );
            Ldb = Ldb - los(rm, fmhz) + Lout;
            sigmadb = sqrt( sigmadb^2 + sigout^2 );

          end

        else % building is too far, treat as NLOS to outside node

          Lbldg = -3 + into_bldg(dd, fmhz, 2, intwalls); % building penetration loss
          sigbldg = 4; % Lbldg standard deviation
          
          % outdoor path loss
          href = max(hind, 2); % outdoor reference point height, m
          if hhn<=1000  % everything is Longly-Rice
                        % use Longley-Rice model
            [ Lout sigout ] = longley_rice(dm/1000, fmhz, [hout href], 90, tpol);

          else % hhn>1000 
               % one antenna is airborne or on mountain 
               % use hybird Longly-Rice with LOS
            dmax = 2e6;   % maximum range for LR model, m
            hmax = 1000;  % maximum height used here for LR model, m
            tantheta = (hhn-hln)/dm; % tangent of prop path elevation angel
            hpn = dmax*tantheta;     % pseudo-node height when range-limited
            if hpn<=hmax; 
              dpn=dmax;  % pseudo-node range
            else         % pseudo-node is height-limited 
              hpn=hmax;  
              dpn=hmax/tantheta; % pseuod-node range when height-limited
            end
            Llos = los(sqrt((hout-href)^2 + dm^2 ), fmhz); % LOS loss
            [ Lobs sigout ] = longley_rice(dpn/1000, fmhz, [hpn href], 90, tpol);
            Lex  = Lobs - los(sqrt((hpn-href)^2 + dpn^2 ), fmhz);
            Lout = Llos + Lex;

          end % end antenna height selection

            % combine building and path loss
            Ldb = Lbldg + Lout;
            sigmadb = sqrt( sigbldg^2 + sigout^2 );

        end % LOS vs NLOS decision

      end % rural, one indoor node, one outdoor
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % rural propagation model with both nodes indoors

      if strncmp(env.scenarioType, 'rural', 5) && ddtx>0 && ddrx>0

        if dm<=10; % same building

          [ Ldb sigmadb ] = indoor_concrete(dm, fmhz, htx, hrx);

        else % nodes in different buildings

          Lbldgtx = into_bldg(ddtx, fmhz, 2, niwallstx); % building penetration loss
          sigbldgtx = 4; % Lbldg standard deviation

          Lbldgrx = into_bldg(ddrx, fmhz, 2, niwallsrx); % building penetration loss
          sigbldgrx = 4; % Lbldg standard deviation
          
          % outdoor path loss 
          htxref = max(htx, 2); % Tx outdoor reference point height, m
          hrxref = max(hrx, 2); % Rx outdoor reference point height, m
          if dm<1000 % use cabot model
            [ Lout sigout ] = cabot(dm, fmhz, htxref, hrxref, 90, tpol);
          else % use Longley-Rice model
            [ Lout sigout ] = longley_rice(dm/1000, fmhz, [htxref hrxref], 90, tpol);
          end

          % combine building and path loss
          Ldb = Lbldgtx + Lbldgrx + Lout;
          sigmadb = sqrt( sigbldgtx^2 + sigbldgrx^2 + sigout^2 );

        end % distance decision

      end % rural propagation, both nodes indoors

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % finish up - shadowing and external noise

      Llos = los(dm, fmhz);        % check that median plus shadowing
      Ldb = max(Ldb, Llos);        % is not lower than LOS loss

      % get external noise figure
      if strncmp(env.scenarioType, 'urban', 5);
        Fext = max(0, manmade(fmhz, 'bus'));
      elseif strncmp(env.scenarioType, 'suburban', 5);
        Fext = max(0, manmade(fmhz, 'res'));  % suburban
      elseif strncmp(env.scenarioType, 'rural', 5);
        Fext = max(0, manmade(fmhz, 'rur'));
      end
      


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Lgt, siggt ] = groundtotower(dm, fmhz, hln, hhn, hrm, pol, env, los_dist)
% function [ Lgt, siggt ] = groundtotower(dm, fmhz, hln, hhn, hrm, pol, env, los_dist);
% find path loss over a wide range of frequencies, when one antenna
% is below roof height, and the other is above. Assumed maximum
% antenna height is 200 m, maximum ground range is 20 km
% inputs: dm   = ground range in m, 1 m to 20 km
%         fmhz = frequency, MHz, 20 MHz to 2 GHz
%         hlm  = lower antenna height, m, must be below roof height
%         hhm  = higher antenna height, m, must be above roof, below 200 m
%         hrm  = roof height, m
%         pol  = polarization, 'v' or 'h'
%         env  = environment, 'U' = urban, 'S' = suburban
%         los_dist = line-of-sight distance, m

if strcmp(env, 'U');  
  henv = 'U2'; % hata model environment flags
  cenv = 1;    % cost-231 walfish ikegami flags
  dh   = 30;   % ground variation
else 
  henv = 'S'; 
  cenv = 0;
  dh   = 30;
end 

if dm<los_dist; % assume LOS
  Lgt = mean2pathflat(dm/1000, hln, hhn, fmhz, pol, 15, 0.005);
  siggt = 0;      
elseif dm<1000  % NLOS, but too short for Hata
  Lgt = cost231(dm/1000, fmhz, hln, hhn, hrm, [], [], [], cenv);
  Lgt = Lgt - cost231(1, fmhz, hln, hhn, hrm, [], [], [], cenv) ...
        + groundtotower(1000, fmhz, hln, hhn, hrm, pol, env, los_dist);
  siggt = okumura_sigma(fmhz, env);
elseif dm>=1000 && fmhz<150 % low frequency: LR sometimes
                            % with Urban Correction
  Lgt = longley_rice(dm/1000, fmhz, [hhn hln], dh, pol);
  if strcmp(env, 'U')
    Lgt = Lgt + longley_urban(dm/1000, fmhz);
  elseif strcmp(env, 'S') 
    Lgt = Lgt + longley_suburban(dm/1000, fmhz);
  end
  siggt = okumura_sigma(fmhz, env);
elseif fmhz<=1500 % vanilla Hata
  Lgt = hata(dm/1000, fmhz, hln, hhn, henv);
  siggt = okumura_sigma(fmhz, env);
else % Hata-Cost
  Lgt = hata_cost(dm/1000, fmhz, hln, hhn, henv);
  siggt = okumura_sigma(fmhz, env);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Lind, sigind ] = indoor_concrete(dm, fmhz, h1, h2, d2w)
% function [ Lind, sigind ] = indoor_concrete(dm, fmhz, h1, h2, d2w);
% find path loss between two antennas inside concrete building
% inputs:  dm   = ground range in m, must be scalar
%          fmhz = frequency, MHz
%          h1   = one antenna height, m, must be scalar
%          h2   = other antenna height, m, must be scalar
%          d2w  = distance from antenna (which one?) to interior wall, m

if nargin<5; d2w = 3; end

rm = sqrt( dm.^2 + abs(h2-h1)^2 ); % slant range

if rm <= 1  % nodes very close
  Lind = los(rm, fmhz);
  sigind = 0;
  
elseif dm<=d2w && abs(h2-h1)<=2 % same room, not so close
  eta = 1.8;
  Lind = los(1, fmhz)+eta*db10(rm);
  sigind = min( (rm-1)*4/(d2w-1), 4);

elseif abs(h2-h1)<=2  % different room in building, same floor
  eta = 2.593+9.490e-4*fmhz-7.254e-8*fmhz^2;
  Lind = los(1, fmhz)+eta*db10(dm);
  sigind = 4;

else   % different floors of building
  nf  = max(round(abs(h2-h1)/3), 1); % number of floors
  nw  = round(dm/7);
  Lind = los(1, fmhz)+db20(rm-1) + ...
         nf*15 + nw*7;
  sigind = 4;

end


% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
% reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above  copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the
%        distribution.
%      * Neither the name of the Massachusetts Institute of Technology nor
%        the names of its contributors may be used to endorse or promote
%        products derived from this software without specific prior written
%        permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


