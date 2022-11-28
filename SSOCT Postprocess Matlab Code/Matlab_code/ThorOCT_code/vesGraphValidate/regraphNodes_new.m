function [nodes, edges, validatedNodes,validatedEdges] = regraphNodes_new(nodes, edges,validatedNodes,idx)


% Re-graph 
nodePos = nodes;
nodeEdges = edges;

nNodes = size(nodePos,1);
nEdges = size(nodeEdges,1);
if ~exist('nodeDiam')
    nodeDiam = zeros(nNodes,1);
end

hxy = 2;
hz = 2;

nNodesUnique = 1;
nodeMap = zeros(nNodes,1);
nodeUnique = zeros(nNodes,1);

nodeMap(1) = 1;
nodePosNew = nodePos(1,:);
nodeUnique(1) = 1;
validatedNodesNew(1) = validatedNodes(1);

hwait = waitbar(0,'Regraphing nodes...');   %modify this if using parfor

for ii=2:nNodes
   if isequal(rem(ii,1000),0)
   waitbar(ii/nNodes,hwait);   %updateing waitbar takes a long time. 
   end
   pos = nodePos(ii,:);
   if validatedNodes(ii)==0  
        lst = find(pos(1)>=(nodePosNew(:,1)-hxy) & pos(1)<=(nodePosNew(:,1)+hxy) & ...
            pos(2)>=(nodePosNew(:,2)-hxy) & pos(2)<=(nodePosNew(:,2)+hxy) & ...
            pos(3)>=(nodePosNew(:,3)-hz) & pos(3)<=(nodePosNew(:,3)+hz) );
        
        % in the lst remove unconnected nodes to current processing node. This will
        % avoid unwanted connections and loops
%         temp_lst = lst;
%         new_lst = [];
%         curr_node = ii;
%         for u = 1:length(lst)
%            node_edges = find(edges(:,1) == curr_node | edges(:,2) == curr_node);
%            conn_nodes = edges(node_edges,:);
%            conn_nodes = conn_nodes(:);
%            common_node = intersect(temp_lst,conn_nodes);
%            if isempty(common_node)
%                break;
%            else
%               new_lst = [new_lst; common_node];
%               curr_node = common_node(1);
%               temp_lst = setdiff(temp_lst,curr_node);
%            end
%         end
%         lst = new_lst;
        
        if isempty(lst)
            nNodesUnique = nNodesUnique+1;

            nodeMap(ii) = nNodesUnique;
            nodeUnique(ii) = 1;

            nodePosNew(nNodesUnique,:) = pos;
            nodeDiamNew(nNodesUnique) = nodeDiam(ii);
            validatedNodesNew(nNodesUnique) = 0;
        else
            if length(lst)>1
                clear d
                for iLst=1:length(lst)
                    d(iLst) = norm(pos-nodePosNew(lst(iLst),:));
                end
                [foo, closestNode] = min(d);
            else
                closestNode = 1;
            end
            nodeMap(ii) = lst(closestNode);
        end
    else  % run this if nodeValidated(ii)==1
               nNodesUnique = nNodesUnique+1;

       nodeMap(ii) = nNodesUnique;
       nodeUnique(ii) = 1;
       
       nodePosNew(nNodesUnique,:) = pos;
       nodeDiamNew(nNodesUnique) = nodeDiam(ii);
        validatedNodesNew(nNodesUnique) = 1;
    end
    
end
close(hwait);

nodeEdgesNew = nodeMap(nodeEdges);
nodeEdges = nodeEdgesNew;

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

% check for new dangling nodes (i.e. nodes with nB=1 that were nB=2
% previously
% if we want to implement this, we just need to have nB_old and nB_new and
% use the nodeMap to find when nB_new=1 and nB_old=2 for given nodes and
% then delete all nodes and edges back to the bifurcation node

% wrap up
nodes = nodePosNew;
validatedNodes = validatedNodesNew';
edges = nodeEdges;
validatedEdges = zeros(size(edges,1),1);
for uu = 1:size(edges,1)
    if validatedNodes(edges(uu,1)) == 1 && validatedNodes(edges(uu,2)) == 1
        validatedEdges(uu) = 1;
    end
end

disp(sprintf('Regraph reduced %d nodes to %d, and %d loops to %d',nNodes,size(nodes,1),...
    nEdges-nNodes+1,size(edges,1)-size(nodes,1)+1))

