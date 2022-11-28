global Data
%nB = zeros(size(Data.Graph.nodes,1),1);
%nN = size(Data.Graph.nodes,1);
%for ii=1:nN
%    nB(ii) = length(find(Data.Graph.edges(:,1)==ii | Data.Graph.edges(:,2)==ii));
%end

% I am looping through all branching nodes
% identify the loops
% delete 1 edge if it meets the condition
nN = size(Data.Graph.nodes,1);
lstN = 1:nN;
lstNbr = find(Data.Graph.nB>2);
nNbr = length(lstNbr);
nEdel = 0;
hwait = waitbar(0,'Pruning loops');
n1 = 0; % keep track of number of nodes for which no loops removed
n2 = 0; % keep track of number of loops not pruned for skipped nodes
while ~isempty(lstNbr)
    iN = lstNbr(end);
    lstNbr = lstNbr(1:end-1);
    waitbar((nNbr-length(lstNbr))/nNbr,hwait);

    % GET SUB GRAPH
    % find nodes within a certain distance of node iN
    pos = Data.Graph.nodes(iN,:);
    r = sum( [(Data.Graph.nodes(:,1)-ones(nN,1)*pos(1)) ...
        (Data.Graph.nodes(:,2)-ones(nN,1)*pos(2))...
        (Data.Graph.nodes(:,3)-ones(nN,1)*pos(3)) ].^2, 2 ).^0.5;
    lstNsub = find(r<30);
    
    % identify edges
    lstE = [];
    for jj=1:length(lstNsub)
        [ir,ic] = find(Data.Graph.edges==lstNsub(jj));
        lstE = [lstE;ir];
    end
    lstE = unique(lstE);
    
    % sub graph
    e = Data.Graph.edges(lstE,:);
    for jj=1:length(lstNsub)
        e(find(e==lstNsub(jj))) = jj;
    end
    % find dangling nodes
    lst = find(e>length(lstNsub));
    for jj = 1:length(lst)
        kk=find(e(lst(jj))==lstNsub);
        if isempty(kk)
            lstNsub(end+1) = e(lst(jj));
            e(lst(jj)) = length(lstNsub);
        else
            e(lst(jj)) = kk;
        end
    end
    
    % find edges connected to nodes with 3+ edges
    E3p = Data.Graph.nB(lstNsub(e(:,1)))>2 & Data.Graph.nB(lstNsub(e(:,2)))>2;

    %
    % identify unique loops if there are any
    nLoops = size(e,1) - length(lstNsub) + 1;
    if nLoops>0
        c = grCycleBasis( e );
        
        % find loops with a unique 3+ edge
        lst = find( (sum(c,2)'.*E3p')==1 );
        % remove no more than one of these edges
        % from each loop and no nodes will be abandoned
        %
        % COULD THIS LEAVE A NODE WITH ONE EDGE IF I INADVERTANTLY REMOVE
        % EDGES FRO A GIVEN NODE TO REDUCE nB TO 1. I SHOULD CHECK THAT
        % nB>2 BEFORE REMOVING AN EDGE... EASY CHECK
        %
        if ~isempty(lst)
            lst3 = [];
            for iLoop = 1:nLoops
                lst2 = find(c(lst,iLoop).*E3p(lst)==1);
                if ~isempty(lst2)
                    iE = lst(lst2(1));
                    if Data.Graph.nB(lstNsub(e(iE,1)))>2 & Data.Graph.nB(lstNsub(e(iE,2)))>2
                        Data.Graph.nB(lstNsub(e(iE,1))) = Data.Graph.nB(lstNsub(e(iE,1))) - 1;
                        Data.Graph.nB(lstNsub(e(iE,2))) = Data.Graph.nB(lstNsub(e(iE,2))) - 1;
                        lst3(end+1) = iE;
                        nEdel = nEdel + 1;
                    end
                end
            end
            Data.Graph.edges(lstE(lst3),:) = [];
        else
            n1 = n1 + 1;
            n2 = n2 + nLoops;
        end
                
    end
end
close(hwait)
disp( sprintf('No loops removed for %d nodes for a total of %d loops skipped',n1,n2) )

% set(handles.textNumEdges,'string',sprintf('%d edges',size(Data.Graph.edges,1)))
% set(handles.uipanelGraph,'title',sprintf('Graph (%d nodes)',size(Data.Graph.nodes,1)));
% 
% set(handles.pushbuttonImageGraph,'enable','on')