function nodeDiam = GetDiam_graph( angio,nodePos, nodeEdges, Ithresh, Hvox )
% This function calculates the diameter for each node position. 
% 
%   Example: nodeDiam = GetDiam_graph( angio,nodePos, nodeEdges, Ithresh, Hvox )
%   
%   Input: angio - angiogram, nodePos - node position of the graph,
%   nodeEdges - edges of the graph, Ithresh - approximate threshold of the
%   segmentation, Hvox - voxel size
%          
%   Output: nodeDiam - Diameter at each node.
%   
%   This is modified GetDiam function from imView3d
%   Modified by Sreekanth Kura - skura@bu.edu




% global im


% if isfield(im,'estDiamFlag')  % flag for running diamter code automatically
%     if im.estDiamFlag==1
%         ch = 1;
%     else
%         ch = menu('Estimate Node Diameters.','All','New','Cancel');
%     end
% else
%     ch = menu('Estimate Node Diameters.','All','New','Cancel');
% end
% 
% if ch==3
%     reEstimated = 0;
%     return;
% end
% reEstimated = 1;


minDiam = 2;
maxDiam = 300;

nodeDiam = zeros(1,size(nodePos,1));
nodeDiamThetaIdx = zeros(1,size(nodePos,1));

%Ithresh = 2;


nx = ceil(maxDiam / Hvox(1));
ny = ceil(maxDiam / Hvox(2));
nz = ceil(maxDiam / Hvox(3));
hx = Hvox(1);
hy = Hvox(2);
hz = Hvox(3);


[nr,nc,ns] = size(angio);


% create mapping of different angular cuts
iTheta = 0;
thetaLst = [0:pi/10:pi-.1];
nTheta = length(thetaLst);
rhoLst = [-maxDiam:1:maxDiam];
nRho = length(rhoLst);
lineMap = zeros(nRho,nTheta);
for iTheta = 1:nTheta
    for iRho = 1:nRho
        xx = rhoLst(iRho) * cos(thetaLst(iTheta));
        yy = rhoLst(iRho) * sin(thetaLst(iTheta));

        ix = round((xx+maxDiam)/hx);
        iy = round((yy+maxDiam)/hy);

        lineMap(iRho,iTheta) = (2*ny+1)*ix + iy + 1;
    end
end

pIdx = [1 2];

hwait = waitbar(0,'Get Diameter...');
nNodes = size(nodePos,1);
for ii = 1:size(nodePos,1)
%     size(nodePos,1)
%     if ch==1 | (ch==2 & im.nodeDiam(ii)==1)
        
        waitbar(ii/nNodes,hwait);
        
        eLst = find(nodeEdges(:,1)==ii | nodeEdges(:,2)==ii);
        
        pos=round(nodePos(ii,:));
        
        if (pos(pIdx(1))-nx)>=1
            dx1 = 1;
            sx1 = pos(pIdx(1))-nx;
        else
            dx1 = nx-pos(pIdx(1))+2;
            sx1 = 1;
        end
        
        if (pos(pIdx(1))+nx)<=nc
            dx2 = 2*nx+1;
            sx2 = pos(pIdx(1))+nx;
        else
            dx2 = 2*nx+1-((pos(pIdx(1))+nx)-nc);
            sx2 = nc;
        end
        
        if (pos(pIdx(2))-ny)>=1
            dy1 = 1;
            sy1 = pos(pIdx(2))-ny;
        else
            dy1 = ny-pos(pIdx(2))+2;
            sy1 = 1;
        end
        
        if (pos(pIdx(2))+ny)<=nr
            dy2 = 2*ny+1;
            sy2 = pos(pIdx(2))+ny;
        else
            dy2 = 2*ny+1-((pos(pIdx(2))+ny)-nr);
            sy2 = nr;
        end
        
        Id = 32*ones(2*ny+1, 2*nx+1);
%         if ch==1 | ch==2
            zrange = min(max(pos(3)-1,1),ns):min(max(pos(3)+1,1),ns);
            Id(dy1:dy2,dx1:dx2) = max(angio(sy1:sy2,sx1:sx2,zrange),[],3);
%         Id(dy1:dy2,dx1:dx2) = angio(sy1:sy2,sx1:sx2,min(pos(3),1));
%         elseif ch==3
%             Id(dy1:dy2,dx1:dx2) = squeeze(angio(sy1:sy2,pos(1),sx1:sx2));
%         end
        Id(find(Id<Ithresh))=0;
        
        
        I1 = Id(lineMap)<Ithresh;
        I2 = [];
        for ii2=1:nTheta
            I2(:,ii2) = imfill(I1(:,ii2), round(nRho/2), [0 1 0;0 1 0;0 1 0]) - I1(:,ii2);
        end
        
        [diam,iTheta] = min(sum(I2,1));
        % If diam = 0 the try to extrapolate out a few voxels to find the
        % vessel
        if diam == 0
            for iOff = 1:3  % this will only extrapolate +/- 3 voxels
                for ii2=1:nTheta
                    I2(:,ii2) = imfill(I1(:,ii2), round(nRho/2)+iOff, [0 1 0;0 1 0;0 1 0]) - I1(:,ii2);
                end
                lstGT0 = find(sum(I2,1)>0);
                if ~isempty(lstGT0)
                    [diam,iThetaTmp] = min(sum(I2(:,lstGT0),1));
                    iTheta = lstGT0(iThetaTmp);
                    break
                end
                for ii2=1:nTheta
                    I2(:,ii2) = imfill(I1(:,ii2), round(nRho/2)-iOff, [0 1 0;0 1 0;0 1 0]) - I1(:,ii2);
                end
                lstGT0 = find(sum(I2,1)>0);
                if ~isempty(lstGT0)
                    [diam,iThetaTmp] = min(sum(I2(:,lstGT0),1));
                    iTheta = lstGT0(iThetaTmp);
                    break
                end
            end
        end
        
        %make sure we respect threshold
        if diam<minDiam
            diam=minDiam;
        elseif diam>maxDiam
            diam=maxDiam;
        end
        
%         im.nodeDiamEst(ii) = diam;
%         im.nodeDiam(ii) = diam;
%         im.nodeDiamThetaIdx(ii) = iTheta; 
          nodeDiam(ii) = diam;
          nodeDiamThetaIdx(ii) = iTheta; 
%     end
end

% if length(im.nodeDiamEst)>nNodes,
%     im.nodeDiamEst(nNodes+1:end) = [];
% end;

close(hwait)