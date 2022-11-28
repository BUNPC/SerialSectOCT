function order_label_cell = fun_graph_get_neighbor_link_by_order(vessel_graph, start_link_label, order)
% fun_graph_get_neighbor_link_by_order get the label of the links that is
% connected to the starting link label and return the label of the links at
% each order into cells 
% Input: 
%   vessel_graph: structure generated by fun_skeleton_to_graph
%   start_link_label: numerical scalar ( can be vector actually ). The
%   label of link(s) to start searching from 
%   order: specify the maximum geodesic distance to the starting link(s) of
%   the returned link label 
% Output: 
%   order_label_cell: order-by-1 cell array, the i-th cell contains the
%   label of thel links that are i edges away from the starting link
% 
% Implemented by Xiang Ji on 07/26/2019

order_label_cell = cell(order, 1);
current_link_label = start_link_label;
for iter_order = 1 : order
    neighbor_node_label = vessel_graph.link.connected_node_label(current_link_label, :);
    neighbor_node_label = neighbor_node_label(neighbor_node_label > 0);
    neighbor_link_label = unique(cat(1, vessel_graph.node.connected_link_label{neighbor_node_label}));
    neighbor_link_label = setdiff(neighbor_link_label, cat(1, order_label_cell{:}));
    order_label_cell{iter_order} = neighbor_link_label;
    current_link_label = neighbor_link_label;
end
end