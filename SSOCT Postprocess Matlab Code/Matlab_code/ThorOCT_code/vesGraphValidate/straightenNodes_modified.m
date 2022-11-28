function nodes = straightenNodes_modified( nodes, edges, Mask, Ithresh,verifiedNodes, idx )

% Move towards mean of neighboring nodes, i.e. straigthening

[ny,nx,nz] = size(Mask);
nN = size(nodes,1);
if nargin < 6
    idx = 1:nN;
end
nodePos = nodes(idx,:);
nodestemp = nodePos;
nLst = 1:size(nodePos,1);
hwait = waitbar(0,'Moving nodes towards mean of neighboring nodes');
for iii= 1:length(nLst) %1:nN
%     ii = nLst(iii);
    if verifiedNodes(idx(iii)) == 0
        ii = idx(iii);
        waitbar(iii/length(nLst),hwait)
        eLst = find(edges(:,1)==ii | edges(:,2)==ii);
        nLst2 = setdiff(unique(edges(eLst,:)), ii);

        proceedFlag=1; % filter nodes on diamter thresshold
        proceedFlag2=1; % select nodes inside Z range
        proceedFlag3=1; % select nodes inside XY range

        if proceedFlag && proceedFlag2 && proceedFlag3
            if length(nLst2)>1
                pos0 = max(nodes(ii,:),1);
                posC = mean(nodes(nLst2,:),1);
                posN = pos0 + (posC-pos0) / max(norm(posC-pos0),1);
                %            if im.I(round(pos0(2)),round(pos0(1)),round(pos0(3)))>=Ithresh
                if Mask(min(max(round(posN(2)),1),ny),min(max(round(posN(1)),1),nx),min(max(round(posN(3)),1),nz))>=Ithresh
                    nodePos(iii,:) = posN;
                end
%                  nodePos(iii,:) = posN;
                %            else
                %                nodePos(ii,:) = posN;
                %            end
            end
        end
    end
    
end
close(hwait)
nodes(idx,:) = nodePos;

