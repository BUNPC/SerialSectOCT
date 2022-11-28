function nodes = centerNodes_transversePlane( nodes, edges, I, idx )

len = size(nodes,1);

if nargin < 4
    idx = 1:len;
end

new_nodes = nodes;
I = permute(I,[3 2 1]);
[ny,nx,nz] = size(I);
h = waitbar(0,'Please wait... Centering nodes(1 and 2 edges)');
for v = 1:len
    waitbar(v/len);
    z = nodes(idx(v),3); x = nodes(idx(v),1); y = nodes(idx(v),2);
    lst = find(edges(:,1) == v | edges(:,2) == v);
    if length(lst) == 2 || length(lst) == 1
        if length(lst) == 2
            n1 = setdiff(edges(lst(1),:),v);
            n2 = setdiff(edges(lst(2),:),v);
        else
            n1 = v;
            n2 = setdiff(edges(lst(1),:),v);
        end    
        FS = 3;
        xc = repmat(-FS:FS,[2*FS+1 1]);
        yc = repmat((-FS:FS)',[1 2*FS+1]);
        zc = zeros(2*FS+1,2*FS+1);
        xx = xc(:);
        yy = yc(:);
        zz = zc(:);
        r1 = nodes(n1,:);
        r2 = nodes(n2,:);
        dr = r1-r2;
        dx = r1(1) - r2(1);
        dz = r1(3) - r2(3);
        r = norm(dr);
        rho = norm(dr(1:2));
        beta = acos(dz/r);
        if rho ~= 0
            gamma = -acos(dx/rho);
        else
            gamma = 0;
        end
        Ry= [cos(beta) 0 -sin(beta); 0 1 0; sin(beta) 0 cos(beta)];
        Rz = [cos(gamma) sin(gamma) 0; -sin(gamma) cos(gamma) 0; 0 0 1];
        foo = Ry*[xx';yy';zz'];
        foo = Rz*foo;
        xx = foo(1,:)';
        yy = foo(2,:)';
        zz = foo(3,:)';
        img = zeros(size(xc(:)));
        for u = 1:size(xc(:))
            img(u) = I(min(max(round(xx(u)+x),1),nx),min(max(round((yy(u)+y)),1),ny),min(max(round(zz(u)+z),1),nz));
        end
        [foo,xyi] = max(img(:));
%         img = reshape(img,[2*FS+1 2*FS+1]);
        new_nodes(v,1) = min(max(z+zz(xyi),1),nz);
        new_nodes(v,2) = min(max(x+xx(xyi),1),nx);
        new_nodes(v,3) = min(max(y+yy(xyi),1),ny);
    else
        new_nodes(v,1) = nodes(v,3);
        new_nodes(v,2) = nodes(v,1);
        new_nodes(v,3) = nodes(v,2);
    end
    
end
close(h);
h = waitbar(0,'Please wait... averaging node positions( >= edges)');
for v = 1:len
    waitbar(v/len);
    z = nodes(v,3); x = nodes(v,1); y = nodes(v,2);
    lst = find(edges(:,1) == v | edges(:,2) == v);
    
    if length(lst) > 2
        node_temp = [0 0 0];
        for jj = 1:length(lst)
            n = setdiff(edges(lst(jj),:),v);
            node_temp = node_temp+nodes(n,:);
        end
        node_temp = node_temp/length(lst);
        new_nodes(v,1) = min(max(node_temp(3),1),nz);
        new_nodes(v,2) = min(max(node_temp(1),1),nx);
        new_nodes(v,3) = min(max(node_temp(2),1),ny);
    end
end
close(h);
nodes(:,1) = new_nodes(:,2);
nodes(:,2) = new_nodes(:,3);
nodes(:,3) = new_nodes(:,1);