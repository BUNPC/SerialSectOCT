function mask = fun_graph_reconstruction(vessel_graph)

recon_ind = cat(1, vessel_graph.node.cc_ind{:}, vessel_graph.link.cc_ind{:});
recon_r = full(vessel_graph.radius(recon_ind));
mask = fun_skeleton_reconstruction(recon_ind, recon_r, vessel_graph.num.mask_size);
end