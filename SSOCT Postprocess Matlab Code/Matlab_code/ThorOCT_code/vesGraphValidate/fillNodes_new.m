function [nodePos, nodeEdges,validatedNodes,verifiedEdges] = fillNodes_new(nodePos, nodeEdges,validatedNodes,verifiedEdges,idx)

hxy = 1;
hz = 1;

h = min(hxy,hz);
nN = size(nodePos,1);
nE = size(nodeEdges,1);
flag = 0;
hwait = waitbar(0,'Filling in sparse edges');
nEo = nE;
for iE = 1:nEo
    if ~rem(iE,1000)
        waitbar(iE/nEo,hwait)
    end
    
    n1 = nodeEdges(iE,1);
    n2 = nodeEdges(iE,2);
    
    if validatedNodes(n1)==0 && validatedNodes(n2)==0
        len = abs( nodePos(n1,:) - nodePos(n2,:) );
        if sum(len>3*[hxy hxy hz])
            flag = 1;
            nStep = max(floor(len ./ [hxy hxy hz]) - 1);
            rStep = (nodePos(n2,:) - nodePos(n1,:)) / (nStep+1);
            pos = nodePos(n1,:);
            for jj=1:nStep
                pos = pos + rStep;
                nodePos(end+1,:) = pos;
                validatedNodes(end+1) = 0;
                nN = nN + 1;
                nodeEdges(end+1,:) = [n1 nN];
                verifiedEdges(end+1) = 0;
                nE = nE + 1;
                n1 = nN;

    %             im.nodeDiam(nN) = 0;
    %             im.nodeDiamThetaIdx(nN) = 0;
    % %            im.nodeVel(nN) = 0;
    %             im.nodeBC(nN) = 0;
    %             im.nodeBCType(nN) = 0;
    %             im.nodeType(nN) = 0;
    %             im.nodeSegN(nN) = 0;
    %             im.edgeFlag(nE) = 0;
            end
            nodeEdges(iE,:) = [nN n2];
        end
    end
    
    %end
end
close(hwait)

