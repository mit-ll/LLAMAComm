function ber = FD_CalculateBER(nodes)

% Function FD_CalculateBER.m:
% Calculates the Bit-Error Rate for full-duplex example.
%
% USAGE:  ber = FD_CalculateBER(nodes)
%
% Input arguments:
%  nodes     (node obj array, 1xN) Node objects
%
% Output arguments:
%  ber       (1x2) UserA->UserB and UserB->UserA BER
%

% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


% Extract user parameters
UA = GetUserParams(FindNode(nodes,'FD_UserA'));
UB = GetUserParams(FindNode(nodes,'FD_UserB'));

% Calculate BER
errAB = find(xor(UA.txBits,UB.rxBits(2:end,:)));
errBA = find(xor(UB.txBits,UA.rxBits(2:end,:)));

berAB = length(errAB)/numel(UA.txBits);
berBA = length(errBA)/numel(UB.txBits);

ber(1) = berAB;
ber(2) = berBA;

% Print results to screen
fprintf('FD_UserA->FD_UserB BER: %f\n',berAB);
fprintf('FD_UserB->FD_UserA BER: %f\n',berBA);






% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


