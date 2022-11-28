% find loops
global Data
endnodes = unique(Data.Graph.segInfo.segEndNodes(:));
numLoops = 0;
numLoopsL2 = 0; numLoops2T4 = 0; numLoopsG4 = 0;
nodeLoop = zeros( size(Data.Graph.nodes,1), 1);
loops = [];

for uu = 1:length(endnodes)
    start_node = endnodes(uu);
    dist_cutoff = 150;   % parameter could be tuned
    dist_nodes = 0;
    edges_processed = [];
    nodes_tobeprocessed = start_node;
    nodes_processed = [];
    currentnode = start_node;
    while ~isempty(nodes_tobeprocessed) 
        while dist_nodes <= dist_cutoff
            nodes_processed = unique([nodes_processed; currentnode]);
            edges_connected = find(Data.Graph.edges(:,1) == currentnode | Data.Graph.edges(:,2) == currentnode);
            edges_processed = unique([edges_processed; edges_connected(:)]);
            connected_nodes = [];
            for u = 1:length(edges_connected)
                temp = Data.Graph.edges(edges_connected(u),:);
                connected_nodes = [connected_nodes; temp(:)];
            end
            nodes_tobeprocessed = setdiff(unique([nodes_tobeprocessed;connected_nodes]),nodes_processed);
            if ~isempty(nodes_tobeprocessed) 
                currentnode = nodes_tobeprocessed(end);
            else
                break;
            end
            dist_nodes = sqrt(sum(Data.Graph.nodes(start_node,:) - Data.Graph.nodes(currentnode,:)).^2);
%             if ~(dist_nodes <= dist_cutoff)
%                 nodes_tobeprocessed = nodes_tobeprocessed(1:end-1);
%                 break;
%             end
        end
        nodes_processed = unique([nodes_processed; currentnode]);
        nodes_tobeprocessed = nodes_tobeprocessed(1:end-1);
        if ~isempty(nodes_tobeprocessed) 
            currentnode = nodes_tobeprocessed(end);
        end
    end  
    edges_new = [];
    for u = 1:length(nodes_processed)
        edges_new = [edges_new; find(Data.Graph.edges(:,1) == nodes_processed(u) | Data.Graph.edges(:,2) == nodes_processed(u))];
    end
    edges_new = unique(edges_new);
    esub = Data.Graph.edges(edges_new,:);
    
    v = unique(esub(:));
    esub2 = esub;
    c(uu).nodes = nodes_processed;
    for iv = 1:length(v)
        esub2(find(esub2==v(iv))) = iv;
    end
    
    c(uu).ind = grCycleBasis(esub2);

    countLoop = [];
    for iLoop = 1:size(c(uu).ind,2)
        countLoop(iLoop) = 0;
        loopNode = [];
        lstEdges = find(c(uu).ind(:,iLoop)>0);
        for iE = 1:length(lstEdges)
            if nodeLoop( esub(lstEdges(iE),1) ) == 0
                nodeLoop( esub(lstEdges(iE),1) ) = numLoops + iLoop;
                countLoop(iLoop) = 1;
                loopNode = esub(lstEdges(iE),1);
            end
            if nodeLoop( esub(lstEdges(iE),2) ) == 0
                nodeLoop( esub(lstEdges(iE),2) ) = numLoops + iLoop;
                countLoop(iLoop) = 1;
                loopNode = esub(lstEdges(iE),2);
            end
        end
        if ~isempty(loopNode)
            loops = [loops; loopNode];
            pt = Data.Graph.nodes(loopNode,:);
            if pt(3) <= 100
                numLoopsL2 = numLoopsL2+1;
            elseif pt(3) > 100 && pt(3) <= 200
                numLoops2T4 = numLoops2T4+1;
            else
                numLoopsG4 = numLoopsG4+1;
            end
        end
    end
    if size(c(uu).ind,2)>0
        numLoops = numLoops + length(find(countLoop>0));
    end
end

Data.Graph.segInfo.loops = loops;
disp([num2str(length(loops)) ' loops are detected in the graph.']);

%%
segmentstodelete = [];
for v = 1:length(Data.Graph.segInfo.loops)   
    nodeno = Data.Graph.segInfo.loops(v);
    if ~isempty(nodeno)
        segmentstodelete = [ segmentstodelete; Data.Graph.segInfo.nodeSegN(nodeno)];
    end
end
nodes = Data.Graph.nodes;
edges = Data.Graph.edges;

%%
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

disp('Loops removed from the graph.');