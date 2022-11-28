global Data
% segLessthan4 = find(Data.Graph.segInfo.segLen <= 4);
nodes = Data.Graph.nodes;
edges = Data.Graph.edges;
segmentstodelete = find(Data.Graph.segInfo.segLen <= 10);
segmentstodelete = intersect(Data.Graph.segInfo.A_idx_end{1,1},segmentstodelete);
lstRemove=[];
for i=1:length(segmentstodelete)
    idx =  find(Data.Graph.segInfo.nodeSegN == segmentstodelete(i));
    endnodes = Data.Graph.segInfo.segEndNodes(segmentstodelete(i),:);
        endnodes = endnodes(:);
        segs1 = find(Data.Graph.segInfo.segEndNodes(:,1) == endnodes(1) | Data.Graph.segInfo.segEndNodes(:,2) == endnodes(1));
        segs2 = find(Data.Graph.segInfo.segEndNodes(:,1) == endnodes(2) | Data.Graph.segInfo.segEndNodes(:,2) == endnodes(2));
        if length(segs1) > 1
            tsegs1 = setdiff(segs1,segmentstodelete);
            if ~isempty(tsegs1)
                idx = setdiff(idx,endnodes(1));
            end
        end
        if length(segs2) > 1
            tsegs2 = setdiff(segs2,segmentstodelete);
            if ~isempty(tsegs2)
                idx = setdiff(idx,endnodes(2));
            end
        end
        lstRemove = [lstRemove; idx];
end
nNodes = size(nodes,1);

map = (1:nNodes)';
map(lstRemove) = [];
mapTemp = (1:length(map))';
nodeMap = zeros(nNodes,1);
nodeMap(map) = mapTemp;

edgesNew = nodeMap(edges);
nodesNew = nodes;
nodesNew(lstRemove,:) = [];

zero_idx = find(edgesNew(:,1) == 0 | edgesNew(:,2)==0);
edgesNew(zero_idx,:) = [];

Data.Graph.nodes = nodesNew;
Data.Graph.edges = edgesNew;

Data.Graph.verifiedNodes = zeros(size(Data.Graph.nodes,1),1);

disp([num2str(length(lstRemove)) ' segments detected and removed from graph']);

