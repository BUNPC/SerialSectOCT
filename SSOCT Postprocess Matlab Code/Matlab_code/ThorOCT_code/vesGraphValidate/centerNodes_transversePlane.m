function nodes = centerNodes_transversePlane( nodes, edges, I,verifiedNodes, idx )

nodes_len = size(nodes,1);

if nargin < 5
    idx = 1:nodes_len;
end
len = length(idx);
new_nodes = nodes;
I = permute(I,[3 2 1]);
[ny,nx,nz] = size(I);
h = waitbar(0,'Please wait... Centering nodes(1 and 2 edges)');
for v = 1:len
    if verifiedNodes(idx(v)) == 0
        waitbar(v/len);
        z = nodes(idx(v),3); x = nodes(idx(v),1); y = nodes(idx(v),2);
        lst = find(edges(:,1) == idx(v) | edges(:,2) == idx(v));
        if length(lst) == 2 || length(lst) == 1
            if length(lst) == 2
                n1 = setdiff(edges(lst(1),:),idx(v));
                n2 = setdiff(edges(lst(2),:),idx(v));
            else
                n1 = idx(v);
                n2 = setdiff(edges(lst(1),:),idx(v));
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
                img(u) = I(min(max(round(xx(u)+x),1),ny),min(max(round((yy(u)+y)),1),nx),min(max(round(zz(u)+z),1),nz));
            end
            [foo,xyi] = max(img(:));
    %         pts = 1:length(img(:));
    %         temp = img(:);
    %         if sum(temp) ~= 0
    %             xyidx = round(pts*temp/sum(temp));
    %         else
    %             xyidx = round(length(img(:))/2);
    %         end
            img = reshape(img,[2*FS+1 2*FS+1]);
            xidx=1:2*FS+1;
            yidx=1:2*FS+1;
            [xgrid,ygrid] = meshgrid(xidx,yidx);
            if sum(img(:))~= 0
                temp = xgrid.*img;
                xidx = round(sum(temp(:))/(sum(img(:))));
                temp = ygrid.*img;
                yidx = round(sum(temp(:))/(sum(img(:))));
            else
                 xidx = round(sum(xgrid(:))/(length(xgrid(:))));
                 yidx = round(sum(ygrid(:))/(length(ygrid(:))));
            end
            xyidx = sub2ind([2*FS+1 2*FS+1],yidx,xidx);
            new_nodes(idx(v),1) = min(max(z+zz(xyidx),1),nz);
            new_nodes(idx(v),2) = min(max(x+xx(xyidx),1),nx);
            new_nodes(idx(v),3) = min(max(y+yy(xyidx),1),ny);
        else
            new_nodes(idx(v),1) = nodes(v,3);
            new_nodes(idx(v),2) = nodes(v,1);
            new_nodes(idx(v),3) = nodes(v,2);
        end
    end
    
end
close(h);
h = waitbar(0,'Please wait... averaging node positions( >= 3edges)');
for v = 1:len
    if verifiedNodes(idx(v)) == 0
        waitbar(v/len);
        z = nodes(idx(v),3); x = nodes(idx(v),1); y = nodes(idx(v),2);
        lst = find(edges(:,1) == idx(v) | edges(:,2) == idx(v));

        if length(lst) > 2
            node_temp = [0 0 0];
            for jj = 1:length(lst)
                n = setdiff(edges(lst(jj),:),idx(v));
                node_temp = node_temp+nodes(n,:);
            end
            node_temp = node_temp/length(lst);
            new_nodes(idx(v),1) = min(max(node_temp(3),1),nz);
            new_nodes(idx(v),2) = min(max(node_temp(1),1),nx);
            new_nodes(idx(v),3) = min(max(node_temp(2),1),ny);
        end
    end
end
close(h);
if nargin >= 4
    nodes(idx,1) = new_nodes(idx,2);
    nodes(idx,2) = new_nodes(idx,3);
    nodes(idx,3) = new_nodes(idx,1);
else
    nodes(:,1) = new_nodes(:,2);
    nodes(:,2) = new_nodes(:,3);
    nodes(:,3) = new_nodes(:,1);
end