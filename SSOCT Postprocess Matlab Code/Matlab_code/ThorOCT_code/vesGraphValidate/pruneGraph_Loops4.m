function [nodePos,nodeDiam,nodeEdges] = pruneGraph_Loops4( im );

nNodes = size(im.nodePos,1);

nE0 = size(im.nodeEdges,1);

nB=zeros(1,nNodes);
for ii=1:nNodes
    nB(ii)=length(find(im.nodeEdges(:,1)==ii | im.nodeEdges(:,2)==ii)); 
end
nBtmp = nB;
nE0 = size(im.nodeEdges,1);

nodeFlag = zeros(nNodes,1);
nodeFlag(find(nB==0)) = 1;

lst = find(nB>=2);


hWait = waitbar(0,'Pruning Loops of 4...');
nLoop = [];
for iiNidx = 1:length(lst)
    nIdx = lst(iiNidx);
    waitbar(find(nIdx==lst)/length(lst),hWait);
    
    if ~nodeFlag(nIdx)

        lstE = find(im.nodeEdges(:,1)==nIdx | im.nodeEdges(:,2)==nIdx);
        nConnTmp = setdiff(unique(im.nodeEdges(lstE,:)),nIdx);
        
        if length(nConnTmp)>=2
            flagStop = 0;
            for i1 = 1:length(nConnTmp)-1
                for i2 = i1+1:length(nConnTmp)
                    nConn = nConnTmp([i1 i2]);


                    lstE1 = find(im.nodeEdges(:,1)==nConn(1) | im.nodeEdges(:,2)==nConn(1));
                    nConn1 = setdiff(unique(im.nodeEdges(lstE1,:)),[nConn(1) nIdx]);

                    lstE2 = [];
                    for ii=1:length(nConn1)
                        lstE2 = [lstE2; find(im.nodeEdges(:,1)==nConn1(ii) | im.nodeEdges(:,2)==nConn1(ii))];
                    end
                    nConn2 = im.nodeEdges(lstE2,:);

                    [iR,iC] = find(nConn2==nConn(2));
                    if ~isempty(iR)
                        %        nLoop = nLoop + length(iR);
                        nLoop(iiNidx) = length(iR);
                        %            [reshape(nConn2(iR,:),[1 length(iR)*2]) nConn']
                        nIdx2 = setdiff(reshape(nConn2(iR,:),[1 length(iR)*2]),[nConn' nIdx]);
                        im.nodePos(nIdx,:) = round(mean(im.nodePos([nIdx nIdx2],:),1));
                        for jj=1:length(nIdx2)
                            lst2 = find(im.nodeEdges==nIdx2(jj));
                            im.nodeEdges(lst2) = nIdx;
                            if ~isempty(find(im.nodeEdges==nIdx2(jj)))
                                keyboard
                            end
                            nodeFlag(nIdx2(jj)) = 1;
                        end
                        flagStop = 1;
                    else
                        nLoop(iiNidx) = 0;
                    end
                    
                    if flagStop
                        break
                    end
                end % end for i2

                if flagStop
                    break
                end
            end % end for i1
        end
    end
    
end
close(hWait)


% remove abandoned nodes
nodePos = im.nodePos;
nodeEdges = im.nodeEdges;
nNodes = size(nodePos,1);
nEdges = size(nodeEdges,1);
if isfield(im,'nodeDiam')
    nodeDiam = im.nodeDiam;
else
    nodeDiam = zeros(nNodes,1);
end

nNodesUnique = 1;
nodeMap = zeros(nNodes,1);
nodeUnique = zeros(nNodes,1);

nodeMap(1) = 1;
nodePosNew = nodePos(1,:);
nodeUnique(1) = 1;

for ii=2:nNodes
    if ~nodeFlag(ii)
        nNodesUnique = nNodesUnique+1;

        nodeMap(ii) = nNodesUnique;
        nodeUnique(ii) = 1;
        
        nodePosNew(nNodesUnique,:) = nodePos(ii,:);
        nodeDiamNew(nNodesUnique) = nodeDiam(ii);
    else
%        nodeMap(ii) = lst(closestNode);
%        [iR, iC]=find(nodeEdges==ii)
    end
end

nodeEdgesNew = nodeMap(nodeEdges);
nodeEdges = nodeEdgesNew;
nodePos = nodePosNew;
nodeDiam = nodeDiamNew;

%%%%%%%%%%%%%%
% prune edges - still need to handle small loops
% point edges
nodeEdges = nodeEdges(find(nodeEdges(:,1)~=nodeEdges(:,2)),:);
% redundant edges
sE = cell(size(nodeEdges,1),1);
for ii=1:length(nodeEdges)
    if nodeEdges(ii,1)<nodeEdges(ii,2)
        sE{ii} = sprintf('%05d%05d',nodeEdges(ii,1),nodeEdges(ii,2));
    else
        sE{ii} = sprintf('%05d%05d',nodeEdges(ii,2),nodeEdges(ii,1));
    end
end
[b,i,j]=unique(sE);
nodeEdges = nodeEdges(sort(i),:);

nEdgesNew = size(nodeEdges,1);




nB2=zeros(1,nNodes);
for ii=1:nNodesUnique
    nB2(ii)=length(find(nodeEdges(:,1)==ii | nodeEdges(:,2)==ii)); 
end
nB2(nNodesUnique+1:nNodes) = 20;

figure
hist([nB' nB2'],[0:20])
title( sprintf('%d edges reduced to %d',nE0,size(nodeEdges,1)) )
    