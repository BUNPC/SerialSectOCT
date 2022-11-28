[filename,pathname] = uigetfile({'*.mat;*.tiff;*.tif'},'Please select the Segmentation Data');
h = waitbar(0,'Please wait... loading the data');
[~,~,ext] = fileparts(filename);

if strcmp(ext,'.mat')
    temp = load([pathname filename]);
    fn = fieldnames(temp);
    angio = temp.(fn{1});
elseif  strcmp(ext,'.tiff') || strcmp(ext,'.tif')
    info = imfinfo([pathname filename]);
    for u = 1:length(info)
        if u == 1
            temp = imread([pathname filename],1);
            angio = zeros([size(temp) length(info)]);
            angio(:,:,u) = temp;
        else
            angio(:,:,u) = imread([pathname filename],u);
        end
    end
end
close(h)

vessel_mask = logical(angio);

% remove islands from raw segments
CC = bwconncomp(vessel_mask);
for uuu = 1:length(CC.PixelIdxList)
    if length(CC.PixelIdxList{uuu}) < 100    % 30 for default
        vessel_mask(CC.PixelIdxList{uuu}) = 0;
    end
end
%%
vessel_skl = bwskel(vessel_mask,'MinBranchLength',1);
%%
vessel_graph = fun_skeleton_to_graph(vessel_skl);
vessel_mask_dt = bwdist(~vessel_mask);
%%

% Size of the angiogram. It will help to convert indeces to subscripts
angio_size = size(vessel_mask);

% find length of nodes to allocate size
nodes_ind_count = length(vessel_graph.node.cc_ind)+length(vessel_graph.link.pos_ind);
nodes_ind = zeros(1,nodes_ind_count);

% find length of edges to allocate size
edges_ind_count = 0;
% link_cc_ind = zeros(size(vessel_graph.link.cc_ind));
for u = 1:length(vessel_graph.node.connected_link_label)
    edges_ind_count = edges_ind_count+length(vessel_graph.node.connected_link_label{u});
end
for  u = 1:length(vessel_graph.link.cc_ind)
    edges_ind_count = edges_ind_count+length(vessel_graph.link.cc_ind{u})-1;
end
% edges_ind_count = edges_ind_count+length(vessel_graph.link.pos_ind);
% idx = find(link_cc_ind == 0);
% for u = 1:length(idx)
%     
% end
edges_ind = zeros(edges_ind_count,2);
%%
% assign nodes and edges
node_idx = 1;
edge_idx = 1;
tttt = [];
link_cc_ind = zeros(size(vessel_graph.link.cc_ind));
for u = 1:length(vessel_graph.node.cc_ind)
    nodes_ind(node_idx) = vessel_graph.node.cc_ind{u}(1);
    tttt = [tttt node_idx];
    temp_node = nodes_ind(node_idx);
    for v = 1:length(vessel_graph.node.connected_link_label{u})
        connected_link = vessel_graph.node.connected_link_label{u}(v);
        connected_link_endnodes = [vessel_graph.link.cc_ind{connected_link}(1) vessel_graph.link.cc_ind{connected_link}(end)];
        [n1,n2,n3] = ind2sub(angio_size,temp_node);
        for w = 1:2
            [l1,l2,l3] = ind2sub(angio_size,connected_link_endnodes(w));
            d(w) = sqrt((n1-l1)^2+(n2-l2)^2+(n3-l3)^2);
        end
        [~,min_idx] = min(d);
        edges_ind(edge_idx,:) = [temp_node connected_link_endnodes(min_idx(1))];
        if link_cc_ind(connected_link) == 0
            link_length = length(vessel_graph.link.cc_ind{connected_link});
            edges_ind(edge_idx+1:edge_idx+link_length-1,1) = vessel_graph.link.cc_ind{connected_link}(1:end-1);
            edges_ind(edge_idx+1:edge_idx+link_length-1,2) = vessel_graph.link.cc_ind{connected_link}(2:end);
            edge_idx = edge_idx+link_length;
            nodes_ind(node_idx+1:node_idx+link_length) = vessel_graph.link.cc_ind{connected_link};
            isa = ismember(nodes_ind(node_idx+1:node_idx+link_length),0);
            tttt = [tttt node_idx+1:node_idx+link_length];
            node_idx = node_idx+link_length;
            link_cc_ind(connected_link) = 1;
        else
            edge_idx = edge_idx+1;
        end
    end
    node_idx = node_idx+1;
end
%%
idx = find(link_cc_ind == 0);
for u = 1:length(idx)
    link_length = length(vessel_graph.link.cc_ind{idx(u)});
    edges_ind(edge_idx+1:edge_idx+link_length-1,1) = vessel_graph.link.cc_ind{idx(u)}(1:end-1);
    edges_ind(edge_idx+1:edge_idx+link_length-1,2) = vessel_graph.link.cc_ind{idx(u)}(2:end);
    edge_idx = edge_idx+link_length;
    nodes_ind(node_idx+1:node_idx+link_length) = vessel_graph.link.cc_ind{idx(u)};
    isa = ismember(nodes_ind(node_idx+1:node_idx+link_length),0);
    tttt = [tttt node_idx+1:node_idx+link_length];
    node_idx = node_idx+link_length;
end

%%

% nodes = zeros(length(nodes_ind),3);
[n1 n2 n3] = ind2sub(angio_size,nodes_ind);
nodes =[n1' n2' n3'];
edges = zeros(size(edges_ind));
%%
for u = 1:size(edges_ind,1)
    edges(u,1) = find(nodes_ind == edges_ind(u,1));
    edges(u,2) = find(nodes_ind == edges_ind(u,2));
end



%%
Graph.nodes = nodes;
Graph.edges = edges;

sameEdgeIdx = [];
for u = 1:size(Graph.edges,1)
    if Graph.edges(u,1) == Graph.edges(u,2)
        sameEdgeIdx = [sameEdgeIdx; u];
    end
end
Graph.edges(sameEdgeIdx,:) = [];
%%
temp = Graph.nodes(:,2);
Graph.nodes(:,2) = Graph.nodes(:,1);
Graph.nodes(:,1) = temp;

% save('frangi_seg.mat','Graph');