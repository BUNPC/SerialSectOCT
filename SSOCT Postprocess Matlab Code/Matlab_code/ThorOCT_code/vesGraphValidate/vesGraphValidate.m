
function varargout = vesGraphValidate(varargin)
% VESGRAPHVALIDATE MATLAB code for vesGraphValidate.fig
%      VESGRAPHVALIDATE, by itself, creates a new VESGRAPHVALIDATE or raises the existing
%      singleton*.
%
%      H = VESGRAPHVALIDATE returns the handle to a new VESGRAPHVALIDATE or the handle
%      tov
%      the existing singleton*.
%
%      VESGRAPHVALIDATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VESGRAPHVALIDATE.M with the given input arguments.
%
%      VESGRAPHVALIDATE('Property','Value',...) creates a new VESGRAPHVALIDATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vesGraphValidate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vesGraphValidate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vesGraphValidate




% Last Modified by GUIDE v2.5 12-Mar-2019 14:10:17



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vesGraphValidate_OpeningFcn, ...
                   'gui_OutputFcn',  @vesGraphValidate_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before vesGraphValidate is made visible.
function vesGraphValidate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vesGraphValidate (see VARARGIN)

% Choose default command line output for vesGraphValidate
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global Data
if exist('Data','var')
    if isfield(Data,'Graph')
        Data = rmfield(Data,'Graph');
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = vesGraphValidate_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untiltled_Callback(hObject, eventdata, handles)
% hObject    handle to Untiltled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function File_loaddata_Callback(hObject, eventdata, handles)
% hObject    handle to File_loaddata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

% clear Data strutre
if exist('Data','var')
    if isstruct(Data)
        names = fieldnames(Data);
        Data = rmfield(Data,names);
    end
end

[filename,pathname] = uigetfile({'*.mat;*.tiff;*.tif'},'Please select the Angiogram Data');
h = waitbar(0,'Please wait... loading the data');
[~,~,ext] = fileparts(filename);
if strcmp(ext,'.mat')
    load([pathname filename]);
    if exist('Output','var')
        if isfield(Data,'angio')
            if ~strcmp(Data.rawdatapath,Output.rawdatapath)
                error('Output raw data path and currently loaded raw data path did not match');
            end
        else
            [~,~,ext] = fileparts(Output.rawdatapath);
            if strcmp(ext,'.mat')
                if ~exist(Output.rawdatapath,'file')
                    error('Raw data was moved from Original location');
                end
                temp = load(Output.rawdatapath);
                fn = fieldnames(temp);
                Data.angio = temp.(fn{1});
            elseif strcmp(ext,'.tiff') || strcmp(ext,'.tif')
                info = imfinfo(Output.rawdatapath);
                for u = 1:length(info)
                    if u == 1
                        temp = imread(Output.rawdatapath,1);
                        angio = zeros([length(info) size(temp)]);
                        angio(u,:,:) = temp;
                    else
                        angio(u,:,:) = imread(Output.rawdatapath,u);
                    end
                end
                Data.angio = angio;
            end
            
            Data.rawdatapath = Output.rawdatapath;
        end
        
         if isfield(Output,'angioVolume')
            Data.angioVolume = double(Output.angioVolume);
        end
        if isfield(Output,'procSteps')
            Data.procSteps = Output.procSteps;
        end
        if isfield(Output,'angioF')
            Data.angioF = Output.angioF;
        end
        if isfield(Output,'angioT')
            Data.angioT = Output.angioT;
        end
        if isfield(Output,'segangio')
            Data.segangio = Output.segangio;
        end
        if isfield(Output,'fv')
            Data.fv = Output.fv;
        end
        if isfield(Output,'Graph')
            Data.Graph = Output.Graph;
            set(handles.checkboxDisplayGraph,'enable','on')
        end
        if isfield(Output,'notes')
            Data.notes = Output.notes;
        end
    else
        temp = load([pathname filename]);
        fn = fieldnames(temp);
        Data.angio = temp.(fn{1});
        Data.rawdatapath = [pathname filename];
    end
elseif strcmp(ext,'.tiff') || strcmp(ext,'.tif')
    info = imfinfo([pathname filename]);
    for u = 1:length(info)
        if u == 1
            temp = imread([pathname filename],1);
            angio = zeros([length(info) size(temp)]);
            angio(u,:,:) = temp;
        else
            angio(u,:,:) = imread([pathname filename],u);
        end
    end
    Data.angio = angio;
    Data.rawdatapath = [pathname filename];
end
maxI = max(Data.angio(:));
minI = min(Data.angio(:));
set(handles.edit_maxI,'String',num2str(maxI));
set(handles.edit_minI,'String',num2str(minI));
[z,x,y] = size(Data.angio);
set(handles.edit_Zstartframe,'String',num2str(1));
set(handles.edit_ZMIP,'String',num2str(z));
% set(handles.edit_XcenterZoom,'String',num2str(1));
% set(handles.edit_XwidthZoom,'String',num2str(x));
% set(handles.edit_YcenterZoom,'String',num2str(1));
% set(handles.edit_YwidthZoom,'String',num2str(y));

set(handles.edit_XcenterZoom,'String',num2str(mean([1 size(Data.angio,2)-1])))
set(handles.edit_YcenterZoom,'String',num2str(mean([1 size(Data.angio,3)-1])))
set(handles.edit_XwidthZoom,'String',num2str(size(Data.angio,2)));
set(handles.edit_YwidthZoom,'String',num2str(size(Data.angio,2)));

% set(handles.edit_imageInfo,'String','Image info');
% set(handles.edit_imageInfo,'String',[num2str(x) 'X' num2str(y) 'X' num2str(z)]);
str = sprintf('%s\n%s','Image info',[num2str(x) 'X' num2str(y) 'X' num2str(z)]);
set(handles.edit_imageInfo,'String',str);
Data.ZoomXrange = [1 size(Data.angio,2)];
Data.ZoomYrange = [1 size(Data.angio,3)];
waitbar(1);
close(h);

draw(hObject, eventdata, handles);


function draw(hObject, eventdata, handles)

global Data


I = Data.angio;
[Sz,Sy,Sx] = size(I);


%%%% Read display range
Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
Zstartframe = min(max(Zstartframe,1),Sz);
ZMIP = str2double(get(handles.edit_ZMIP,'String'));
Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
Xstartframe = str2double(get(handles.edit_XcenterZoom,'String'));
XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
Xstartframe = min(max(Xstartframe-XMIP/2,1),Sx);
Xendframe = min(max(Xstartframe+XMIP,1),Sx);
Ystartframe = str2double(get(handles.edit_YcenterZoom,'String'));
YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
Ystartframe = min(max(Ystartframe-YMIP/2,1),Sy);
Yendframe = min(max(Ystartframe+YMIP,1),Sy);
Data.ZoomXrange = [Xstartframe Xendframe];
Data.ZoomYrange = [Ystartframe Yendframe];
Data.ZoomZrange = [Zstartframe Zendframe];
Zimg = squeeze(max(I(Zstartframe:Zendframe,:,:),[],1));
ZimgXZ = squeeze(max(I(:,Ystartframe:Yendframe,:),[],2));
ZimgYZ = squeeze(max(I(:,:,Xstartframe:Xendframe),[],3));
%Ximg = squeeze(max(I(:,Xstartframe:Xendframe,:),[],2));
%Yimg = squeeze(max(I(:,:,Ystartframe:Yendframe),[],3));
%ZMIPimg = squeeze(max(I,[],1));

% if isfield(Data,'segangio') && (get(handles.checkbox_showSeg,'Value') == 1)
%     ZimgS = squeeze(max(Data.segangio(Zstartframe:Zendframe,:,:),[],1));
%     %    XimgS = squeeze(max(Data.segangio(:,Xstartframe:Xendframe,:),[],2));
%     %    YimgS = squeeze(max(Data.segangio(:,:,Ystartframe:Yendframe),[],3));
%     %    imgS = squeeze(max(Data.segangio,[],1));
% end

axes(handles.axes1)
if 1
    cmap(254,:) = [1 0 1];
    cmap(255,:) = [0 1 0];
    cmap(252,:) = [1 0 1];
    cmap(253,:) = [0 1 0];
    cmap(251,:) = [1 1 0];
else
    cmap(254,:) = [1 0 1];
    cmap(255,:) = [0 1 0];
    cmap(252,:) = [1 1 0];
    cmap(253,:) = [1 1 1];
end

if get(handles.checkbox_verifySegments,'Value') && (isfield(Data,'Graph') && isfield(Data.Graph,'segInfo'))
    
    set(handles.text_segNumber,'String','segment');
    set(handles.edit_segmentNumber,'String',num2str(Data.Graph.segno));
    set(handles.text_segNumber2,'String',[' of ' num2str(size(Data.Graph.segInfo.segPos,1))]);
    
    if strcmp(get(handles.AllSegments_nBG3,'checked'),'on')
        if ~isfield(Data.Graph,'nodeno')
            Data.Graph.nodeno = 1;
        end
        nBG3_idx = find(Data.Graph.nB>3);
        nBG3 = Data.Graph.endNodes(nBG3_idx);
        nodeno = nBG3(Data.Graph.nodeno);
        segs = unique(find(Data.Graph.segInfo.segEndNodes(:,1) == nodeno | Data.Graph.segInfo.segEndNodes(:,2) == nodeno));
        segslength = Data.Graph.segInfo.segLen(segs);
        [~,idx] = min(segslength);
        %         [~,idx] = min(abs(nBG3 -Data.Graph.segno));
        Data.Graph.segno = segs(idx(1));
        seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(Data.Graph.nodeno) ' of ' num2str(length(nBG3)) ')'];
    elseif strcmp(get(handles.AllSegments_loops,'checked'),'on')
        if ~isfield(Data.Graph.segInfo,'loopno')
            Data.Graph.segInfo.loopno = 1;
        end
        nodeno = Data.Graph.segInfo.loops(Data.Graph.segInfo.loopno);
        Data.Graph.segno = Data.Graph.segInfo.nodeSegN(nodeno);
        seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(Data.Graph.segInfo.loopno) ' of ' num2str(length(Data.Graph.segInfo.loops)) ')'];
    else
        if  strcmp(get(handles.Groups_All,'checked'),'off')
            if strcmp(get(handles.verification_allSegments,'checked'),'on')
                idx = find(Data.Graph.segInfo.segmentsGrpOrder(:,1) == Data.Graph.segno);
                group_no = Data.Graph.segInfo.segmentsGrpOrder(idx,2);
                set(handles.text_segNumber,'String','segment');
                set(handles.edit_segmentNumber,'String',num2str(Data.Graph.segno));
                set(handles.text_segNumber2,'String',[' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (Group-'  num2str(group_no) ')']);
            elseif strcmp(get(handles.unverified,'checked'),'on')
                idx = find(Data.Graph.segInfo.segmentsUnverifiedGrpOrder(:,1) == Data.Graph.segno);
                group_no = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(idx,2);
                set(handles.text_segNumber,'String','segment');
                set(handles.edit_segmentNumber,'String',num2str(Data.Graph.segno));
                set(handles.text_segNumber2,'String',[' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (Group-'  num2str(group_no) ' & ' num2str(idx) ' of ' num2str(length(Data.Graph.segInfo.segmentsUnverifiedGrpOrder)) ')']);
            end
        else
            if strcmp(get(handles.AllSegments_All,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.A_idx_end{1,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_idx_end{1,1},1)) ')'];
                    str2 = num2str(Data.Graph.segno);
                    str3 = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_idx_end{1,1},2)) ')'];
                else
                    %                 set(handles.text_segNumber,'String',['segment ' num2str(Data.Graph.segno) ' of ' num2str(size(Data.Graph.segInfo.segPos,1))]);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1))];
                end
            elseif strcmp(get(handles.AllSegments_lessthan3nodes,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.A_idx_end{2,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_idx_end{2,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.A_Idx3 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_Idx3,1)) ')'];
                end
            elseif strcmp(get(handles.AllSegments_lessthan5nodes,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.A_idx_end{3,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_idx_end{3,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.A_Idx5 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_Idx5,1)) ')'];
                end
            elseif strcmp(get(handles.AllSegments_lessthan10nodes,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.A_idx_end{4,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_idx_end{4,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.A_Idx10 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.A_Idx10,1)) ')'];
                end
            elseif strcmp(get(handles.unverifedlessthan3Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.idx_end{2,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.idx_end{2,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.unverifiedIdx3 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.unverifiedIdx3,1)) ')'];
                end
            elseif strcmp(get(handles.unverifedlessthan3Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.idx_end{2,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.idx_end{2,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.unverifiedIdx3 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.unverifiedIdx3,1)) ')'];
                end
            elseif strcmp(get(handles.unverifedlessthan5Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.idx_end{3,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.idx_end{3,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.unverifiedIdx5 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.unverifiedIdx5,1)) ')'];
                end
            elseif strcmp(get(handles.unverifedlessthan10Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.idx_end{4,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.idx_end{4,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.unverifiedIdx10 == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.unverifiedIdx10,1)) ')'];
                end
            elseif strcmp(get(handles.unverifedAllNodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'Checked'),'on')
                    idx = find(Data.Graph.segInfo.idx_end{1,1} == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.idx_end{1,1},1)) ')'];
                else
                    idx = find(Data.Graph.segInfo.unverifiedIdx == Data.Graph.segno);
                    seginfo_text = [' of ' num2str(size(Data.Graph.segInfo.segPos,1)) ' (' num2str(idx) ' of ' num2str(size(Data.Graph.segInfo.unverifiedIdx,1)) ')'];
                end
            end
        end
    end
    if exist('seginfo_text','var')
        set(handles.text_segNumber,'String','segment');
        set(handles.edit_segmentNumber,'String',num2str(Data.Graph.segno));
        set(handles.text_segNumber2,'String', seginfo_text);
        %         set(handles.text_segNumber,'String',seginfo_text);
    end
    
    maxI = str2double(get(handles.edit_maxI,'String'));
    minI = str2double(get(handles.edit_minI,'String'));
    colormap('gray')
    if get(handles.radiobutton_XYview,'Value')
        I_h = imagesc(Zimg,[minI maxI]);
    elseif get(handles.radiobutton_XZview,'Value')
        I_h = imagesc(ZimgXZ,[minI maxI]);
    else
        I_h = imagesc(ZimgYZ,[minI maxI]);
    end
    axis image;
    axis on
    if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
        if get(handles.radiobutton_XYview,'Value')
            xlim(Data.ZoomXrange);
            ylim(Data.ZoomYrange);
        elseif get(handles.radiobutton_XZview,'Value')
            xlim(Data.ZoomXrange);
            ylim(Data.ZoomZrange);
        else
            xlim(Data.ZoomYrange);
            ylim(Data.ZoomZrange);
        end
    end
    if get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1
        set(I_h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
    end
    nodes = Data.Graph.nodes;
    edges = Data.Graph.edges;
    %     nodeSegN = Data.Graph.segInfo.nodeSegN;
    %     Seg_count = max(nodeSegN(:));
    %     ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    %     XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    %     YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    %     if isfield(Data.Graph,'segno')
    %         u = Data.Graph.segno;
    %     else
    %         u = 1;
    %         Data.Graph.segno = u;
    %     end
    %     seg_nodes = find(nodeSegN == u);
    %     Data.Graph.verifiedNodes(seg_nodes) = 3;
    hold on
    lstvisible = find(nodes(:,1)>=Data.ZoomXrange(1) & nodes(:,1)<=Data.ZoomXrange(2) & ...
        nodes(:,2)>=Data.ZoomYrange(1) & nodes(:,2)<=Data.ZoomYrange(2) & ...
        nodes(:,3)>=Zstartframe & nodes(:,3)<=Zendframe & Data.Graph.verifiedNodes == 1 );
    endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
    lstseg = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);
    %      lstseg = intersect(lstseg,lstvisible);
    if isfield(Data.Graph,'segmentstodelete')
        if sum(ismember(Data.Graph.segmentstodelete,Data.Graph.segno)) ~= 0
            cn = 'r.';
            ce = 'r-';
        elseif Data.Graph.verifiedSegments(Data.Graph.segno) == 1
            cn = 'g.';
            ce = 'g-';
        else
            cn ='c.';
            ce = 'c-';
        end
    else
        if Data.Graph.verifiedSegments(Data.Graph.segno) == 1
            cn = 'g.';
            ce = 'g-';
        else
            cn ='c.';
            ce = 'c-';
        end
    end
    %      h=plot(nodes(lstseg,1),nodes(lstseg,2),cn);
    if get(handles.radiobutton_XYview,'Value')
        h=plot(nodes(lstseg,1),nodes(lstseg,2),cn);
    elseif get(handles.radiobutton_XZview,'Value')
        h=plot(nodes(lstseg,1),nodes(lstseg,3),cn);
    else
        h=plot(nodes(lstseg,2),nodes(lstseg,3),cn);
    end
    lstseg_edges = find(Data.Graph.segInfo.edgeSegN == Data.Graph.segno);
    for ii = 1:length(lstseg_edges)
        %           h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
        if get(handles.radiobutton_XYview,'Value')
            h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
        elseif get(handles.radiobutton_XZview,'Value')
            h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),3), ce );
        else
            h = plot(nodes(edges(lstseg_edges(ii),:),2), nodes(edges(lstseg_edges(ii),:),3), ce );
        end
    end
    %      for ii=1:length(lstseg)
    %             lst2 = find(edges(:,1)==lstseg(ii));
    %             h = plot(nodes(edges(lst2,:),1), nodes(edges(lst2,:),2), ce );
    % %                h = plot(nodes(edges(lst2,:),1), 'm-' );
    % %             if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
    % %                  || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
    % %                 set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
    % %             end
    %      end
    hold off
    
    u1 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,1);
    u2 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,2);
    idx1 = find((Data.Graph.segInfo.segEndNodes(:,1) == u1) | (Data.Graph.segInfo.segEndNodes(:,2) == u1));
    idx2 = find((Data.Graph.segInfo.segEndNodes(:,1) == u2) | (Data.Graph.segInfo.segEndNodes(:,2) == u2));
    idx = setdiff([idx1;idx2],Data.Graph.segno);
    
    %%%Display segments to delete
    for uu = 1:length(idx)
        if isfield(Data.Graph,'segmentstodelete')
            if sum(ismember(Data.Graph.segmentstodelete,idx(uu))) ~= 0
                cn = 'r.';
                ce = 'r-';
            else
                cn = 'm.';
                ce = 'm-';
            end
        else
            cn = 'm.';
            ce = 'm-';
        end
        hold on
        seg_nodes = find(Data.Graph.segInfo.nodeSegN == idx(uu));
        %            h=plot(nodes(seg_nodes,1),nodes(seg_nodes,2),cn);
        if get(handles.radiobutton_XYview,'Value')
            h=plot(nodes(seg_nodes,1),nodes(seg_nodes,2),cn);
        elseif get(handles.radiobutton_XZview,'Value')
            h=plot(nodes(seg_nodes,1),nodes(seg_nodes,3),cn);
        else
            h=plot(nodes(seg_nodes,2),nodes(seg_nodes,3),cn);
        end
        lstseg_edges = find(Data.Graph.segInfo.edgeSegN == idx(uu));
        for ii = 1:length(lstseg_edges)
            %                h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
            if get(handles.radiobutton_XYview,'Value')
                h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
            elseif get(handles.radiobutton_XZview,'Value')
                h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),3), ce );
            else
                h = plot(nodes(edges(lstseg_edges(ii),:),2), nodes(edges(lstseg_edges(ii),:),3), ce );
            end
        end
        %          seg_nodes = intersect(seg_nodes,lstvisible);
        %          h=plot(nodes(seg_nodes,1),nodes(seg_nodes,2),'m.');
        %          for ii=1:length(seg_nodes)
        %              lst2 = find(edges(:,1)==seg_nodes(ii));
        %              h = plot(nodes(edges(lst2,:),1), nodes(edges(lst2,:),2), 'm-' );
        %          end
        hold off
    end
    guigcf = gcf;
    if 1
        fig_handle = figure(1); subplot(2,2,1); I_h = imagesc(Zimg,[minI maxI]); axis image; axis on
        if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
            xlim(Data.ZoomXrange);
            ylim(Data.ZoomYrange);
        end
        hold on
        if isfield(Data.Graph,'segmentstodelete')
            if sum(ismember(Data.Graph.segmentstodelete,Data.Graph.segno)) ~= 0
                cn = 'r.';
                ce = 'r-';
            elseif Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                cn = 'g.';
                ce = 'g-';
            else
                cn ='c.';
                ce = 'c-';
            end
        else
            if Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                cn = 'g.';
                ce = 'g-';
            else
                cn ='c.';
                ce = 'c-';
            end
        end
        h=plot(nodes(lstseg,1),nodes(lstseg,2),cn);
        lstseg_edges = find(Data.Graph.segInfo.edgeSegN == Data.Graph.segno);
        for ii = 1:length(lstseg_edges)
            h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce);
        end
        %      for ii=1:length(lstseg)
        %             lst2 = find(edges(:,1)==lstseg(ii));
        %             h = plot(nodes(edges(lst2,:),1), nodes(edges(lst2,:),2), ce );
        % %                h = plot(nodes(edges(lst2,:),1), 'm-' );
        % %             if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
        % %                  || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
        % %                 set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
        % %             end
        %      end
        for uu = 1:length(idx)
            if isfield(Data.Graph,'segmentstodelete')
                if sum(ismember(Data.Graph.segmentstodelete,idx(uu))) ~= 0
                    cn = 'r.';
                    ce = 'r-';
                else
                    cn = 'm.';
                    ce = 'm-';
                end
            else
                cn = 'm.';
                ce = 'm-';
            end
            seg_nodes = find(Data.Graph.segInfo.nodeSegN == idx(uu));
            %          seg_nodes = intersect(seg_nodes,lstvisible);
            h=plot(nodes(seg_nodes,1),nodes(seg_nodes,2),cn);
            lstseg_edges = find(Data.Graph.segInfo.edgeSegN == idx(uu));
            for ii = 1:length(lstseg_edges)
                h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
            end
            %          for ii=1:length(seg_nodes)
            %              lst2 = find(edges(:,1)==seg_nodes(ii));
            %              h = plot(nodes(edges(lst2,:),1), nodes(edges(lst2,:),2), ce );
            %          end
        end
        
        hold off
        
        Ximg = squeeze(max(I(:,Ystartframe:Yendframe,:),[],2));
        subplot(2,2,3); imagesc(Ximg,[minI maxI]); colormap('gray');
        axis image;
        axis on
        if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
            xlim(Data.ZoomXrange);
            ylim(Data.ZoomZrange);
        end
        hold on
        if isfield(Data.Graph,'segmentstodelete')
            if sum(ismember(Data.Graph.segmentstodelete,Data.Graph.segno)) ~= 0
                cn = 'r.';
                ce = 'r-';
            elseif Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                cn = 'g.';
                ce = 'g-';
            else
                cn ='c.';
                ce = 'c-';
            end
        else
            if Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                cn = 'g.';
                ce = 'g-';
            else
                cn ='c.';
                ce = 'c-';
            end
        end
        x = 1; y= 3;
        h=plot(nodes(lstseg,x),nodes(lstseg,y),cn);
        lstseg_edges = find(Data.Graph.segInfo.edgeSegN == Data.Graph.segno);
        for ii = 1:length(lstseg_edges)
            h = plot(nodes(edges(lstseg_edges(ii),:),x), nodes(edges(lstseg_edges(ii),:),y), ce);
        end
        %          for ii=1:length(lstseg)
        %              lst2 = find(edges(:,1)==lstseg(ii));
        %              h = plot(nodes(edges(lst2,:),x), nodes(edges(lst2,:),y), ce );
        %              %                h = plot(nodes(edges(lst2,:),1), 'm-' );
        %              %             if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
        %              %                  || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
        %              %                 set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
        %              %             end
        %          end
        hold off
        for uu = 1:length(idx)
            if isfield(Data.Graph,'segmentstodelete')
                if sum(ismember(Data.Graph.segmentstodelete,idx(uu))) ~= 0
                    cn = 'r.';
                    ce = 'r-';
                else
                    cn = 'm.';
                    ce = 'm-';
                end
            else
                cn = 'm.';
                ce = 'm-';
            end
            hold on
            seg_nodes = find(Data.Graph.segInfo.nodeSegN == idx(uu));
            %          seg_nodes = intersect(seg_nodes,lstvisible);
            h=plot(nodes(seg_nodes,x),nodes(seg_nodes,y),cn);
            lstseg_edges = find(Data.Graph.segInfo.edgeSegN == idx(uu));
            for ii = 1:length(lstseg_edges)
                h = plot(nodes(edges(lstseg_edges(ii),:),x), nodes(edges(lstseg_edges(ii),:),y), ce );
            end
            %              for ii=1:length(seg_nodes)
            %                  lst2 = find(edges(:,1)==seg_nodes(ii));
            %                  h = plot(nodes(edges(lst2,:),x), nodes(edges(lst2,:),y), 'm-' );
            %              end
            hold off
        end
        
        Yimg = squeeze(max(I(:,:,Xstartframe:Xendframe),[],3));
        subplot(2,2,2); imagesc(Yimg',[minI maxI]); colormap('gray');
        axis image;
        axis on
        if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
            xlim(Data.ZoomZrange);
            ylim(Data.ZoomYrange);
        end
        hold on
        if isfield(Data.Graph,'segmentstodelete')
            if sum(ismember(Data.Graph.segmentstodelete,Data.Graph.segno)) ~= 0
                cn = 'r.';
                ce = 'r-';
            elseif Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                cn = 'g.';
                ce = 'g-';
            else
                cn ='c.';
                ce = 'c-';
            end
        else
            if Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                cn = 'g.';
                ce = 'g-';
            else
                cn ='c.';
                ce = 'c-';
            end
        end
        x = 3; y= 2;
        h=plot(nodes(lstseg,x),nodes(lstseg,y),cn);
        lstseg_edges = find(Data.Graph.segInfo.edgeSegN == Data.Graph.segno);
        for ii = 1:length(lstseg_edges)
            h = plot(nodes(edges(lstseg_edges(ii),:),x), nodes(edges(lstseg_edges(ii),:),y), ce);
        end
        %          for ii=1:length(lstseg)
        %              lst2 = find(edges(:,1)==lstseg(ii));
        %              h = plot(nodes(edges(lst2,:),x), nodes(edges(lst2,:),y), ce );
        %              %                h = plot(nodes(edges(lst2,:),1), 'm-' );
        %              %             if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
        %              %                  || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
        %              %                 set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
        %              %             end
        %          end
        hold off
        for uu = 1:length(idx)
            if isfield(Data.Graph,'segmentstodelete')
                if sum(ismember(Data.Graph.segmentstodelete,idx(uu))) ~= 0
                    cn = 'r.';
                    ce = 'r-';
                else
                    cn = 'm.';
                    ce = 'm-';
                end
            else
                cn = 'm.';
                ce = 'm-';
            end
            hold on
            seg_nodes = find(Data.Graph.segInfo.nodeSegN == idx(uu));
            %          seg_nodes = intersect(seg_nodes,lstvisible);
            h=plot(nodes(seg_nodes,x),nodes(seg_nodes,y),cn);
            lstseg_edges = find(Data.Graph.segInfo.edgeSegN == idx(uu));
            for ii = 1:length(lstseg_edges)
                h = plot(nodes(edges(lstseg_edges(ii),:),x), nodes(edges(lstseg_edges(ii),:),y), ce );
            end
            %              for ii=1:length(seg_nodes)
            %                  lst2 = find(edges(:,1)==seg_nodes(ii));
            %                  h = plot(nodes(edges(lst2,:),x), nodes(edges(lst2,:),y), ce );
            %              end
            hold off
        end
        if strcmp(get(handles.AllSegments_nBG3,'checked'),'on')
%             button =uicontrol('Parent',fig_handle,'Style','pushbutton','String','Select Points','Units','normalized','Position',[0.75 0.25 0.1 0.1],'Visible','on');
            button =uicontrol(fig_handle,'Style','pushbutton','String','Select Points','Units','normalized','Position',[0.75 0.25 0.1 0.1],'Visible','on');
            button.Callback = @select_points;
        end
        
        figure(2)
        clf
        n = ceil((Data.ZoomZrange(2)-Data.ZoomZrange(1))/10);
        n1 = ceil(n/4);
        for iii = 1:n
            ha(iii)=subplot(n1,4,iii);
            colormap('gray')
            img10 = squeeze(max(I(Zstartframe+(iii-1)*10:min(Zstartframe+(iii-1)*10,Zendframe),:,:),[],1));
            imagesc(img10,[minI maxI]);
            axis on
            axis image
            if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
                xlim(Data.ZoomXrange);
                ylim(Data.ZoomYrange);
            end
            if isfield(Data.Graph,'segmentstodelete')
                if sum(ismember(Data.Graph.segmentstodelete,Data.Graph.segno)) ~= 0
                    cn = 'r.';
                    ce = 'r-';
                elseif Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                    cn = 'g.';
                    ce = 'g-';
                else
                    cn ='c.';
                    ce = 'c-';
                end
            else
                if Data.Graph.verifiedSegments(Data.Graph.segno) == 1
                    cn = 'g.';
                    ce = 'g-';
                else
                    cn ='c.';
                    ce = 'c-';
                end
            end
            hold on
            h=plot(nodes(lstseg,1),nodes(lstseg,2),cn);
            lstseg_edges = find(Data.Graph.segInfo.edgeSegN == Data.Graph.segno);
            for ii = 1:length(lstseg_edges)
                h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
            end
            for uu = 1:length(idx)
                if isfield(Data.Graph,'segmentstodelete')
                    if sum(ismember(Data.Graph.segmentstodelete,idx(uu))) ~= 0
                        cn = 'r.';
                        ce = 'r-';
                    else
                        cn = 'm.';
                        ce = 'm-';
                    end
                else
                    cn = 'm.';
                    ce = 'm-';
                end
                seg_nodes = find(Data.Graph.segInfo.nodeSegN == idx(uu));
                %          seg_nodes = intersect(seg_nodes,lstvisible);
                h=plot(nodes(seg_nodes,1),nodes(seg_nodes,2),cn);
                lstseg_edges = find(Data.Graph.segInfo.edgeSegN == idx(uu));
                for ii = 1:length(lstseg_edges)
                    h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
                end
                %                   for ii=1:length(seg_nodes)
                %                       lst2 = find(edges(:,1)==seg_nodes(ii));
                %                       h = plot(nodes(edges(lst2,:),1), nodes(edges(lst2,:),2), ce );
                %                   end
                
            end
            
            hold off
        end
        %          linkaxes(ha,'xy')
    end
    %      uicontrol(guigcf);
    figure(guigcf);
    
else
    if get(handles.radiobutton_fastDisplay,'Value') && isfield(Data,'angioVolume')
        cmap = gray(255);
        if 1
            cmap(254,:) = [1 0 1];
            cmap(255,:) = [0 1 0];
            cmap(252,:) = [1 0 1];
            cmap(253,:) = [0 1 0];
            cmap(251,:) = [1 1 0];
        else
            cmap(254,:) = [1 0 1];
            cmap(255,:) = [0 1 0];
            cmap(252,:) = [1 1 0];
            cmap(253,:) = [1 1 1];
        end
        Zimg = squeeze(max(Data.angioVolume(Zstartframe:Zendframe,:,:),[],1));
        I_h = imagesc(Zimg,[0 256]);
        colormap(cmap);
        axis image
        axis on
        if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
            xlim(Data.ZoomXrange);
            ylim(Data.ZoomYrange);
        end
        if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
                || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
            set(I_h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
        end
    else
        colormap('gray')
        maxI = str2double(get(handles.edit_maxI,'String'));
        minI = str2double(get(handles.edit_minI,'String'));
        if get(handles.radiobutton_XYview,'Value')
            I_h = imagesc(Zimg,[minI maxI]);
        elseif get(handles.radiobutton_XZview,'Value')
            I_h = imagesc(ZimgXZ,[minI maxI]);
        else
            I_h = imagesc(ZimgYZ,[minI maxI]);
        end
        axis image
        axis on
        if isfield(Data,'ZoomXrange') && isfield(Data,'ZoomYrange')
            if get(handles.radiobutton_XYview,'Value')
                xlim(Data.ZoomXrange);
                ylim(Data.ZoomYrange);
            elseif get(handles.radiobutton_XZview,'Value')
                xlim(Data.ZoomXrange);
                ylim(Data.ZoomZrange);
            else
                xlim(Data.ZoomYrange);
                ylim(Data.ZoomZrange);
            end
        end
        % Display Graph
        if isfield(Data,'Graph') && get(handles.checkboxDisplayGraph,'value')==1
            nodes = Data.Graph.nodes;
            edges = Data.Graph.edges;
            lst = find(nodes(:,1)>=Data.ZoomXrange(1) & nodes(:,1)<=Data.ZoomXrange(2) & ...
                nodes(:,2)>=Data.ZoomYrange(1) & nodes(:,2)<=Data.ZoomYrange(2) & ...
                nodes(:,3)>=Zstartframe & nodes(:,3)<=Zendframe );
            %      if isfield(Data.Graph,'verifiedNodes')
            %          c = blanks(length(lst));
            %          c(1:length(lst)) = 'm.';
            %          lst1 = find(lst & Data.Graph.verifiedNodes == 1);
            %          c(lst1) = 'g.';
            %          lst2 = find(lst & Data.Graph.verifiedNodes == 2);
            %          c(lst2) = 'g*';
            %      else
            %          c = 'm.';
            %      end
            %     c = 'm.';
            hold on
            %         h=plot(nodes(lst,1),nodes(lst,2),'m.');
            if get(handles.radiobutton_XYview,'Value')
                h=plot(nodes(lst,1),nodes(lst,2),'m.');
            elseif get(handles.radiobutton_XZview,'Value')
                h=plot(nodes(lst,1),nodes(lst,3),'m.');
            else
                h=plot(nodes(lst,2),nodes(lst,3),'m.');
            end
            % for u = 1:length(lst)
            %
            % end
            
            if isfield(Data.Graph,'verifiedNodes')
                lstg = find(nodes(:,1)>=Data.ZoomXrange(1) & nodes(:,1)<=Data.ZoomXrange(2) & ...
                    nodes(:,2)>=Data.ZoomYrange(1) & nodes(:,2)<=Data.ZoomYrange(2) & ...
                    nodes(:,3)>=Zstartframe & nodes(:,3)<=Zendframe & Data.Graph.verifiedNodes >= 1 );
                %              h=plot(nodes(lstg,1),nodes(lstg,2),'g.');
                if get(handles.radiobutton_XYview,'Value')
                    h=plot(nodes(lstg,1),nodes(lstg,2),'g.');
                elseif get(handles.radiobutton_XZview,'Value')
                    h=plot(nodes(lstg,1),nodes(lstg,3),'g.');
                else
                    h=plot(nodes(lstg,2),nodes(lstg,3),'g.');
                end
                
                %              lsts = find(nodes(:,1)>=Data.ZoomXrange(1) & nodes(:,1)<=Data.ZoomXrange(2) & ...
                %                    nodes(:,2)>=Data.ZoomYrange(1) & nodes(:,2)<=Data.ZoomYrange(2) & ...
                %                    nodes(:,3)>=Zstartframe & nodes(:,3)<=Zendframe & Data.Graph.verifiedNodes == 2 );
                %              h=plot(nodes(lsts,1),nodes(lsts,2),'g*','MarkerSize',15);
                %              lstseg = find(nodes(:,1)>=Data.ZoomXrange(1) & nodes(:,1)<=Data.ZoomXrange(2) & ...
                %                    nodes(:,2)>=Data.ZoomYrange(1) & nodes(:,2)<=Data.ZoomYrange(2) & ...
                %                    nodes(:,3)>=Zstartframe & nodes(:,3)<=Zendframe & Data.Graph.verifiedNodes == 3 );
                %              h=plot(nodes(lstseg,1),nodes(lstseg,2),'g.');
            end
            set(h,'markersize',12)
            if isfield(Data.Graph,'segmentstodelete')
                segmentstodelete = Data.Graph.segmentstodelete;
                lstRemove = [];
                noteEndNodes = [];
                for u = 1:length(segmentstodelete)
                    idx = find(Data.Graph.segInfo.nodeSegN == segmentstodelete(u));
                    endnodes = Data.Graph.segInfo.segEndNodes(segmentstodelete(u),:);
                    endnodes = endnodes(:);
                    segs1 = find(Data.Graph.segInfo.segEndNodes(:,1) == endnodes(1) | Data.Graph.segInfo.segEndNodes(:,2) == endnodes(1));
                    segs2 = find(Data.Graph.segInfo.segEndNodes(:,1) == endnodes(2) | Data.Graph.segInfo.segEndNodes(:,2) == endnodes(2));
                    if length(segs1) > 1
                        tsegs1 = setdiff(segs1,segmentstodelete);
                        if ~isempty(tsegs1)
                            idx = setdiff(idx,endnodes(1));
                            if length(segs1) == 3
                                noteEndNodes = [noteEndNodes; endnodes(1)];
                            end
                            Data.Graph.segInfo.nodeSegN(endnodes(1)) = tsegs1(1);
                        end
                    end
                    if length(segs2) > 1
                        tsegs2 = setdiff(segs2,segmentstodelete);
                        if ~isempty(tsegs2)
                            idx = setdiff(idx,endnodes(2));
                            if length(segs1) == 3
                                noteEndNodes = [noteEndNodes; endnodes(2)];
                            end
                            Data.Graph.segInfo.nodeSegN(endnodes(2)) = tsegs2(1);
                        end
                    end
                    lstRemove = [lstRemove; idx];
%                     if isempty(idx)
%                           edgeidx = find((Data.Graph.edges(:,1) == endnodes(1) & Data.Graph.edges(:,2) == endnodes(2))|...
%                               (Data.Graph.edges(:,1) == endnodes(2) & Data.Graph.edges(:,2) == endnodes(1)));
%                           Data.Graph.edges(edgeidx,:) = [];
%                           Data.Graph.segInfo.edgeSegN(edgeidx) = [];
%                     end
                end
                 h=plot(nodes(lstRemove,1),nodes(lstRemove,2),'r.');
%                  foo = ismember(edges,lstRemove);
%                 lste = find(sum(foo,2)==2);
%                 h = plot([nodes(edges(lste,1),1) nodes(edges(lste,2),1)]', [nodes(edges(lste,1),2) nodes(edges(lste,2),2)]', 'r-' );
            end
            if isfield(Data.Graph,'nodeS')
                if ~isempty(Data.Graph.nodeS)
                    pt = Data.Graph.nodeS;
                    plot(nodes(pt,1),nodes(pt,2),'b*','MarkerSize',15);
                end
            end
            
            if 1
                foo = ismember(edges,lst);
                lst2 = find(sum(foo,2)==2);
                %                 h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', 'm-' );
                if get(handles.radiobutton_XYview,'Value')
                    h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', 'm-' );
                elseif get(handles.radiobutton_XZview,'Value')
                    h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),3) nodes(edges(lst2,2),3)]', 'm-' );
                else
                    h = plot([nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', [nodes(edges(lst2,1),3) nodes(edges(lst2,2),3)]', 'm-' );
                end
                %                h = plot(nodes(edges(lst2,:),1), 'm-' );
                if isfield(Data.Graph,'segmentstodelete')
                    foo = ismember(edges,lstRemove);
                    lste = find(sum(foo,2)==2);
                    h = plot([nodes(edges(lste,1),1) nodes(edges(lste,2),1)]', [nodes(edges(lste,1),2) nodes(edges(lste,2),2)]', 'r-' );
                end
                if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
                        || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
                    set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
                end
            else
                for ii=1:length(lst)
                    lst2 = find(edges(:,1)==lst(ii));
                    h = plot(nodes(edges(lst2,:),1)', nodes(edges(lst2,:),2)', 'm-' );
                    %                h = plot(nodes(edges(lst2,:),1), 'm-' );
                    if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
                            || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
                        set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
                    end
                end
            end
            if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
                    || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
                set(I_h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
            end
            
            %%%%%%
            %%% uncomment below lines to display verified nodes in xy and
            %%% yz mode
%                     if isfield(Data.Graph,'verifiedNodes')
%                          foo = ismember(edges,lstg);
%                         lst2 = find(sum(foo,2)==2);
%             %                 h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', 'g-' );
%                             if get(handles.radiobutton_XYview,'Value')
%                                 h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', 'g-' );
%                             elseif get(handles.radiobutton_XZview,'Value')
%                                 h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,3),1)]', [nodes(edges(lst2,2),2) nodes(edges(lst2,3),2)]', 'g-' );
%                             else
%                                 h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,3),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,3),2)]', 'g-' );
%                             end
%                             %                h = plot(nodes(edges(lst2,:),1), 'm-' );
%                             if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
%                                     || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
%                                 set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
%                             end
%             %             for ii=1:length(lstg)
%             %                 lst2 = find(edges(:,1)==lstg(ii));
%             %                 h = plot(nodes(edges(lst2,:),1), nodes(edges(lst2,:),2), 'g-' );
%             %                 if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
%             %                      || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
%             %                     set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
%             %                 end
%             %             end
%                     end
            %%%%%%%
            lsttemp = lst;
            seglst = [];
            
            %                                         while ~isempty(lsttemp)
            %                                             lstnode = lsttemp(1);
            %                                             segtemp = Data.Graph.segInfo.nodeSegN(lstnode);
            %                                             nodeslst = find(Data.Graph.segInfo.nodeSegN == segtemp);
            %                                             lsttemp = setdiff(lsttemp,nodeslst);
            %                                             seglst = [seglst; segtemp];
            %                                         end
            %
            %                                 %
            %                                         idx = find(ismember(Data.Graph.segmentstodelete,seglst) == 1);
            %                                         seglst = Data.Graph.segmentstodelete(idx);
            %                                         nodesidx = find(ismember(Data.Graph.segInfo.nodeSegN,seglst)==1);
            %                                         nodesidx = nodesidx(find(ismember(nodesidx,lst)==1));
            %                                         endNodes = Data.Graph.segInfo.segEndNodes(seglst,:);
            %                                         nodesidx = unique([nodesidx;endNodes(:)]);
            %                                         h=plot(nodes(nodesidx,1),nodes(nodesidx,2),'r.');
            %                                         foo = ismember(edges,nodesidx);
            %                                         lst2 = find(sum(foo,2)==2);
            %                                         edgesidx = find(ismember(Data.Graph.segInfo.edgeSegN,seglst)==1);
            %                                         edgesidx =  edgesidx(find(ismember(edgesidx,lst2)==1));
            %                                         for ii = 1:length(edgesidx)
            %                                             h = plot(nodes(edges(edgesidx(ii),:),1), nodes(edges(edgesidx(ii),:),2), 'r-' );
            %                                             if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
            %                                                     || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
            %                                                 set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
            %                                             end
            %                                         end
            
            %         for u = 1:length(seglst)
            %
            %             h=plot(nodes(lstseg,1),nodes(lstseg,2),cn);
            %             lstseg_edges = find(Data.Graph.segInfo.edgeSegN == Data.Graph.segno);
            %             for ii = 1:length(lstseg_edges)
            %                 h = plot(nodes(edges(lstseg_edges(ii),:),1), nodes(edges(lstseg_edges(ii),:),2), ce );
            %             end
            %         end
            
            
            %         foo = ismember(edges,nodesidx);
            %         lst2 = find(sum(foo,2)==2);
            %         h = plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', 'r-' );
            %                h = plot(nodes(edges(lst2,:),1), 'm-' );
            %         if get(handles.radiobutton_validateNodes,'Value') == 1 || get(handles.radiobutton_addEdge,'Value') == 1 ...
            %                 || get(handles.radiobutton_selectSegment,'Value') == 1 || get(handles.radiobutton_unvalidateNodes,'Value') == 1
            %             set(h, 'ButtonDownFcn', {@axes_ButtonDown, handles});
            %         end
            hold off
        end
    end
end

if isfield(Data,'Graph') && isfield(Data.Graph,'addSegment') && (get(handles.checkbox_verifySegments,'Value') ||  get(handles.checkboxDisplayGraph,'value')==1)
    hold on
    plot(Data.Graph.addSegment(:,1),Data.Graph.addSegment(:,2),'m*');
    % plot([nodes(edges(lst2,1),1) nodes(edges(lst2,2),1)]', [nodes(edges(lst2,1),2) nodes(edges(lst2,2),2)]', 'm-' );
    plot(Data.Graph.addSegment(:,1),Data.Graph.addSegment(:,2),'m-');
    hold off
end

% % Display nodes and edges information
% if isfield(Data,'Graph')
%     nodes1 = 0;
%     nodes2 = 0;
%     nodesg2 = 0;
%     for u = 1:size(Data.Graph.nodes,1)
%         lst = find(Data.Graph.edges(:,1) == u | Data.Graph.edges(:,2) == u);
%         if length(lst) == 1
%             nodes1 = nodes1+1;
%         end
%         if length(lst) == 2
%             nodes2 = nodes2+1;
%         end
%          if length(lst) > 2
%             nodesg2 = nodesg2+1;
%         end
%     end
% str = sprintf('%s\n%s\n%s\n%s','Nodes info',['One edge nodes -' num2str(nodes1)],...
%     ['Two edge nodes -' num2str(nodes2)],...
%     ['More than two edge nodes -' num2str(nodesg2)]);
% set(handles.edit_NodesInfo,'String',str);
% end






function axes_ButtonDown(hObject, eventdata, handles)

global Data

parent = (get(hObject, 'Parent'));
pts = get(parent, 'CurrentPoint');
y = pts(1,1);
x = pts(1,2);
[Sz,Sx,Sy] = size(Data.angio);
Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
Zstartframe = min(max(Zstartframe,1),Sz);
ZMIP = str2double(get(handles.edit_ZMIP,'String'));
Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
parent = get(parent,'parent');
mouseclick = get(parent, 'SelectionType');

if get(handles.radiobutton_validateNodes,'Value') == 1
    
    if ~isfield(Data.Graph,'verifiedNodes')
        Data.Graph.verifiedNodes = zeros(size(Data.Graph.nodes,1),1);
    end
    if ~isfield(Data.Graph,'verifiedEdges')
        Data.Graph.verifiedEdges = zeros(size(Data.Graph.edges,1),1);
    end
    
    % find the indices close to the selected point
    s = 5;
    idx = find(Data.Graph.nodes(:,2) >= x-s & Data.Graph.nodes(:,2) <= x+s ...
            & Data.Graph.nodes(:,1) >= y-s & Data.Graph.nodes(:,1) <= y+s ...
            & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
    
    % find the closet point
    min_idx = 1;
    for u = 1:length(idx)
        idx_x = Data.Graph.nodes(idx(u),2);
        idx_y = Data.Graph.nodes(idx(u),1);
        if u == 1
            min_dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
        else
            dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
            if dist < min_dist
                min_dist = dist;
                min_idx = u;
            end
        end
    end
     
    if ~isempty(idx)    
        if strcmp(mouseclick,'normal')
    %         idx = find(Data.Graph.nodes(:,2) >= x-1 & Data.Graph.nodes(:,2) <= x+1 ...
    %             & Data.Graph.nodes(:,1) >= y-1 & Data.Graph.nodes(:,1) <= y+1 ...
    %             & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
            if isfield(Data,'node1')
                tempnode = Data.node1;
            end
            Data.node1 = idx(min_idx);
            Data.Graph.verifiedNodes(idx(min_idx)) = 2;
            if get(handles.radiobutton_fastDisplay,'Value')  
                if exist('tempnode','var')
                    pos = Data.Graph.nodes(tempnode,:);
                    Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 254;
                end
                pos = Data.Graph.nodes(Data.node1,:);
                Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 251;
            end
        elseif strcmp(mouseclick,'alt')
    %        idx = find(Data.Graph.nodes(:,2) >= x-1 & Data.Graph.nodes(:,2) <= x+1 ...
    %             & Data.Graph.nodes(:,1) >= y-1 & Data.Graph.nodes(:,1) <= y+1 ...
    %             & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
            Data.node2 = idx(min_idx);
            if isfield(Data,'node1')
                if length(Data.node1) == 1
                    nlst = [];
                    cnode = Data.node1;
                    path = cnode;
                    pathtemp = [];
                    branchidx = 0;
                    count =0;
                    maxbranch = 3;
                    while(count < 1000) 
                        count = count + 1
        %                 [costs,paths] = dijkstra(Data.Graph.nodes,Data.Graph.edges,Data.node1,Data.node2,1);
                        eidx = find(Data.Graph.edges(:,1) == cnode | Data.Graph.edges(:,2) == cnode);
                        nidx = [];
                        for u = 1:length(eidx)
                            nidx = [nidx Data.Graph.edges(eidx(u),:)];
                        end
                        nidx = setdiff(nidx, path);
                        if length(nidx) > 1
                            branchidx = branchidx+1;
                            temp = [nidx(2:end)' branchidx*ones(size(nidx(2:end)'))];
                            if branchidx < maxbranch+1
    %                             nlst = [nlst nidx(2:end)];
                                nlst = [nlst; temp];
                                pathtemp = [pathtemp length(path)];
                                cnode = nidx(1);
                                path = [path cnode];
                            end
                        elseif length(nidx) == 1
                            cnode = nidx(1);
                            path = [path cnode];
                        end
    %                     if branchidx > maxbranch
    %                          cnode = nlst(end-1);
    %                     end
                        if (isempty(nidx) || branchidx > maxbranch+1) 
                            if ~isempty(nlst)
                                cnode = nlst(end,1);
                                if length(pathtemp) > 0
                                    path(pathtemp(end)+1:end) = [];
                                    pathtemp(end) = [];
                                end
                                branchidx = nlst(end,2);
                                nlst(end,:) = [];
                                path = [path cnode];
    %                             branchidx = max(0,branchidx - 1);
                            else
                                path = [];
                                break;
                            end
                        end 
                        if ~isempty(find(ismember(nidx,Data.node2)))
                            break;
                        end
    %                      if ~isempty(path)
    %                         Data.Graph.verifiedNodes(path) = 1;
    %                         Data.Graph.verifiedNodes(end) = 2;
    %                     end
    %                     draw(hObject, eventdata, handles);
                    end
                end
                if ~isempty(path)
                    Data.Graph.verifiedNodes(path) = 1;
                    Data.Graph.verifiedNodes(Data.Graph.verifiedNodes ~= 0) = 1;
                    Data.Graph.verifiedNodes(path(end)) = 2;
                    Data.node1 = Data.node2;
                    for u = 1:length(path)-1
%                         idx = find(Data.Graph.edges(:,1) == path(u) & Data.Graph.edges(:,1) == path(u+1))
%                         Data.Graph.verifiedEdges(idx) = 1;
                          idx = find(Data.Graph.edges(:,1) == path(u) | Data.Graph.edges(:,2) == path(u));
                          for v = 1:length(idx) 
                              pt = setdiff(Data.Graph.edges(idx(v),:),path(u));
                              if ismember(pt,path)
                                  nodes = Data.Graph.nodes;
                                  edges = Data.Graph.edges;
                                  Data.Graph.verifiedEdges(idx(v)) = 1;
                                  if get(handles.radiobutton_fastDisplay,'Value')
                                      edgetemp  = Data.Graph.edges(idx(v),:);
                                      pos0 = max(nodes(edgetemp(1),:),1);
                                      pos1 = max(nodes(edgetemp(2),:),1);
                                      rsep = norm(pos1-pos0);
                                      if rsep>0
                                          cxyz = (pos1-pos0) / rsep;
                                          rstep = 0;
                                          pos = pos0;
                                          while rstep<rsep
                                              %             im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
                                              Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 252+1*Data.Graph.verifiedEdges(idx(v));
                                              pos = pos + cxyz*0.5;
                                              %if pos(1)<2 & pos(2)<2
                                              %    keyboard
                                              %end
                                              rstep = rstep + 0.5;
                                          end
                                      end
                                      idx1 = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
                                      Data.angioVolume(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
                                      idx1 = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
                                      Data.angioVolume(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
                                      %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
                                      %     angio(Z,Y,X) = 254;
%                                       if isfield(Data,'node1')
%                                           Data = rmfield(Data,'node1');
%                                       end
                                  end
                              end
                          end
%                           epts = Data.Graph.edges(eidx(u),:);
%                           epts = setdiff(epts,path(u));
                    end
                end
            end
        end
    end
elseif get(handles.radiobutton_addEdge,'Value') == 1
    % find the indices close to the selected point
    s = 5;
    idx = find(Data.Graph.nodes(:,2) >= x-s & Data.Graph.nodes(:,2) <= x+s ...
        & Data.Graph.nodes(:,1) >= y-s & Data.Graph.nodes(:,1) <= y+s ...
        & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
    % find the closet point
    min_idx = 1;
    for u = 1:length(idx)
        idx_x = Data.Graph.nodes(idx(u),2);
        idx_y = Data.Graph.nodes(idx(u),1);
        if u == 1
            min_dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
        else
            dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
            if dist < min_dist
                min_dist = dist;
                min_idx = u;
            end
        end
    end
    [~,Zidx] = max(Data.angio(Zstartframe:Zendframe,round(x),round(y)));
    if strcmp(mouseclick,'normal')
%         if ~isempty(idx)
            if isfield(Data.Graph,'addSegment')
                if isempty(Data.Graph.addSegment)
                    if ~isempty(idx)
                        Data.Graph.addSegment = Data.Graph.nodes(idx(min_idx),:);
                        Data.Graph.addSegmentSnode = idx(min_idx);
                    end
                else
                    Data.Graph.addSegment = [Data.Graph.addSegment; [y x Zstartframe+Zidx-1]];
                    %                      Data.Graph.addSegment = [Data.Graph.addSegment; Data.Graph.nodes(idx(min_idx),:)];
                    %                      Data.Graph.addSegmentEnode = idx(min_idx);
                    %                      addSegment(hObject, eventdata, handles)
                end
            else
                if ~isempty(idx)
                    Data.Graph.addSegment = Data.Graph.nodes(idx(min_idx),:);
                    Data.Graph.addSegmentSnode = idx(min_idx);
                end
            end
%         end
    elseif strcmp(mouseclick,'alt')
        if isfield(Data.Graph,'addSegment') && ~isempty(Data.Graph.addSegment)
%             Data.Graph.addSegment = [Data.Graph.addSegment; [y x Zstartframe]]; 
              if ~isempty(idx)
                  Data.Graph.addSegment = [Data.Graph.addSegment; Data.Graph.nodes(idx(min_idx),:)];
                  Data.Graph.addSegmentEnode = idx(min_idx);
                  addSegment(hObject, eventdata, handles)
              end
        end
    end
%     if ~isempty(idx) 
%          if strcmp(mouseclick,'normal')
%              Data.Graph.nodeS = idx(min_idx);
%              if get(handles.radiobutton_fastDisplay,'Value')
%                 pos = Data.Graph.nodes(Data.Graph.nodeS,:);
%                 Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 251;
%             end
%          elseif strcmp(mouseclick,'alt')
%              if ~isfield(Data.Graph,'nodeS')
%                  h = msgbox('You did not select starting point to add edge');
%                  uiwait(h);
%              else
%                  Data.Graph.edges = [Data.Graph.edges; [Data.Graph.nodeS idx(min_idx)]];
%                  if isfield(Data.Graph,'verifiedEdges')
%                      Data.Graph.verifiedEdges = [Data.Graph.verifiedEdges; 1];
%                      nodes = Data.Graph.nodes;
%                      edges = Data.Graph.edges;
%                      if get(handles.radiobutton_fastDisplay,'Value')
%                          edgetemp  = Data.Graph.edges(end,:);
%                          pos0 = max(nodes(edgetemp(1),:),1);
%                          pos1 = max(nodes(edgetemp(2),:),1);
%                          rsep = norm(pos1-pos0);
%                          if rsep>0
%                              cxyz = (pos1-pos0) / rsep;
%                              rstep = 0;
%                              pos = pos0;
%                              while rstep<rsep
%                                  %             im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
%                                  Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 252+1*Data.Graph.verifiedEdges(end);
%                                  [max(round(pos(3)),1) round(pos(2)) round(pos(1))]
%                                  pos = pos + cxyz*0.5;
%                                  %if pos(1)<2 & pos(2)<2
%                                  %    keyboard
%                                  %end
%                                  rstep = rstep + 0.5;
%                              end
%                          end
%                          idx1 = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
%                          Data.angioVolume(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
%                          idx1 = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
%                          Data.angioVolume(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
%                          %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
%                          %     angio(Z,Y,X) = 254;
%                          
%                      end
%                  end
%                  
%                  Data.Graph = rmfield(Data.Graph,'nodeS');
%              end
%          end
%     end
    
elseif get(handles.radiobutton_selectSegment,'Value') == 1  
%     & get(handles.checkbox_verifySegments,'Value')
    % find the indices close to the selected point
    s = 5;
    idx = find(Data.Graph.nodes(:,2) >= x-s & Data.Graph.nodes(:,2) <= x+s ...
            & Data.Graph.nodes(:,1) >= y-s & Data.Graph.nodes(:,1) <= y+s ...
            & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
    
    % find the closet point
    min_idx = 1;
    for u = 1:length(idx)
        idx_x = Data.Graph.nodes(idx(u),2);
        idx_y = Data.Graph.nodes(idx(u),1);
        if u == 1
            min_dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
        else
            dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
            if dist < min_dist
                min_dist = dist;
                min_idx = u;
            end
        end
    end
    seg_node = idx(min_idx);
    undoDelete_flag = 0;
    idx_seg = find(Data.Graph.segInfo.segEndNodes(:,1) == seg_node | Data.Graph.segInfo.segEndNodes(:,2) == seg_node);
    if length(idx_seg) < 1
        selected_segment = Data.Graph.segInfo.nodeSegN(seg_node);
    else 
        ambiguityflag = 1;
        for u = 1:length(idx_seg)
            if length(find(Data.Graph.segInfo.nodeSegN == idx_seg(u))) == 1
                selected_segment = idx_seg(u);
                 ambiguityflag = 0;
                 break;
            end
        end
        if ambiguityflag == 1
            f = msgbox('Please select different node,current node is part of multiple segments');
            uiwait(f);
            return
        end
    end
%     list = {'Delete','Verify'};
%     [indx,tf] = listdlg('ListString',list);
    if isfield(Data.Graph,'segmentstodelete')
         if sum(ismember(Data.Graph.segmentstodelete,selected_segment)) > 0
             choice = menu('Select segment','Verify','Undelete','cancel');
         else
             choice = menu('Select segment','Verify','Delete','cancel');
         end
    else
        choice = menu('Select segment','Verify','Delete','cancel');
    end
    if choice == 1
        pushbutton_verifySegment_Callback(hObject, eventdata, handles, selected_segment)
    elseif choice == 2
        if isfield(Data.Graph,'segmentstodelete')
            if sum(ismember(Data.Graph.segmentstodelete,selected_segment)) > 0
                idx = find(Data.Graph.segmentstodelete == selected_segment);
                undoDelete_flag = 1;
                Data.Graph.segmentstodelete(idx) = [];
            else
                Data.Graph.segmentstodelete = [Data.Graph.segmentstodelete; selected_segment];
            end
        else
            Data.Graph.segmentstodelete = selected_segment;
        end
        draw(hObject, eventdata, handles);
        if undoDelete_flag == 0
            answer = questdlg(['Are you sure you want to delete the segment ' num2str(Data.Graph.segmentstodelete(end)) '?'], 'Delete segment','No');
            if ~strcmp(answer,'Yes')
                Data.Graph.segmentstodelete(end) = [];
            end
        else
            answer = questdlg(['Are you sure you want to undelete the segment ' num2str(selected_segment) '?'], 'Delete segment','No');
            if ~strcmp(answer,'Yes')
                Data.Graph.segmentstodelete(end) = idx;
            end
        end
        draw(hObject, eventdata, handles);
    end
%     if ~isempty(idx) 
%          if strcmp(mouseclick,'normal')
%              Data.Graph.node1 = idx(min_idx);
%               if get(handles.radiobutton_fastDisplay,'Value')
% %                 pos = Data.Graph.nodes(Data.node1,:);
%                 pos = Data.Graph.nodes(Data.Graph.node1,:);
%                 Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 251;
%               end
%          elseif strcmp(mouseclick,'alt')
%              Data.node2 = idx(min_idx);
%              if ~isfield(Data.Graph,'node1')
%                  h = msgbox('You did not select starting point to add edge');
%                  uiwait(h);
%              else
% %                  idx = find((Data.Graph.edges(:,1) == Data.Graph.nodeS & Data.Graph.edges(:,2) == idx(min_idx)) | ...
% %                      (Data.Graph.edges(:,2) == Data.Graph.nodeS & Data.Graph.edges(:,1) == idx(min_idx)));
% %                  Data.Graph.edges(idx,:) = [];
% 
%                 nlst = [];
%                 cnode = Data.Graph.node1;
%                 path = cnode;
%                 pathtemp = [];
%                 branchidx = 0;
%                 count =0;
%                 maxbranch = 3;
%                 while(count < 1000)
%                     count = count + 1
%                     %                 [costs,paths] = dijkstra(Data.Graph.nodes,Data.Graph.edges,Data.node1,Data.node2,1);
%                     eidx = find(Data.Graph.edges(:,1) == cnode | Data.Graph.edges(:,2) == cnode);
%                     nidx = [];
%                     for u = 1:length(eidx)
%                         nidx = [nidx Data.Graph.edges(eidx(u),:)];
%                     end
%                     nidx = setdiff(nidx, path);
%                     if length(nidx) > 1
%                         branchidx = branchidx+1;
%                         temp = [nidx(2:end)' branchidx*ones(size(nidx(2:end)'))];
%                         if branchidx < maxbranch+1
%                             %                             nlst = [nlst nidx(2:end)];
%                             nlst = [nlst; temp];
%                             pathtemp = [pathtemp length(path)];
%                             cnode = nidx(1);
%                             path = [path cnode];
%                         end
%                     elseif length(nidx) == 1
%                         cnode = nidx(1);
%                         path = [path cnode];
%                     end
%                     %                     if branchidx > maxbranch
%                     %                          cnode = nlst(end-1);
%                     %                     end
%                     if (isempty(nidx) || branchidx > maxbranch+1)
%                         if ~isempty(nlst)
%                             cnode = nlst(end,1);
%                             if length(pathtemp) > 0
%                                 path(pathtemp(end)+1:end) = [];
%                                 pathtemp(end) = [];
%                             end
%                             branchidx = nlst(end,2);
%                             nlst(end,:) = [];
%                             path = [path cnode];
%                             %                             branchidx = max(0,branchidx - 1);
%                         else
%                             path = [];
%                             break;
%                         end
%                     end
%                     if ~isempty(find(ismember(nidx,Data.node2)))
%                         break;
%                     end
%                     %                      if ~isempty(path)
%                     %                         Data.Graph.verifiedNodes(path) = 1;
%                     %                         Data.Graph.verifiedNodes(end) = 2;
%                     %                     end
%                     %                     draw(hObject, eventdata, handles);
%                 end
%                 if ~isempty(path)
%                     Data.Graph.verifiedNodes(path) = 0;
% %                     Data.Graph.verifiedNodes(Data.Graph.verifiedNodes ~= 0) = 1;
%                     Data.Graph.verifiedNodes(path(end)) = 0;
%                     Data.node1 = Data.node2;
%                     for u = 1:length(path)-1
% %                         idx = find(Data.Graph.edges(:,1) == path(u) & Data.Graph.edges(:,1) == path(u+1))
% %                         Data.Graph.verifiedEdges(idx) = 1;
%                           idx = find(Data.Graph.edges(:,1) == path(u) | Data.Graph.edges(:,2) == path(u));
%                           for v = 1:length(idx) 
%                               pt = setdiff(Data.Graph.edges(idx(v),:),path(u));
%                               if ismember(pt,path)
%                                   nodes = Data.Graph.nodes;
%                                   edges = Data.Graph.edges;
%                                   Data.Graph.verifiedEdges(idx(v)) = 0;
%                                   if get(handles.radiobutton_fastDisplay,'Value')
%                                       edgetemp  = Data.Graph.edges(idx(v),:);
%                                       pos0 = max(nodes(edgetemp(1),:),1);
%                                       pos1 = max(nodes(edgetemp(2),:),1);
%                                       rsep = norm(pos1-pos0);
%                                       if rsep>0
%                                           cxyz = (pos1-pos0) / rsep;
%                                           rstep = 0;
%                                           pos = pos0;
%                                           while rstep<rsep
%                                               %             im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
%                                               angiovalue = Data.angio(max(round(pos(3)),1),round(pos(2)),round(pos(1)));
%                                               Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 250*(angiovalue-min(Data.angio(:)))/(max(Data.angio(:))-min(Data.angio(:)));
% %                                               Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 252+1*Data.Graph.verifiedEdges(idx(v));
%                                               pos = pos + cxyz*0.5;
%                                               %if pos(1)<2 & pos(2)<2
%                                               %    keyboard
%                                               %end
%                                               rstep = rstep + 0.5;
%                                           end
%                                       end
% %                                       idx1 = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
%                                       angiovalue = Data.angio(max(round(pos0(3)),1),round(pos0(2)),round(pos0(1)));
%                                       Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 250*(angiovalue-min(Data.angio(:)))/(max(Data.angio(:))-min(Data.angio(:)));
%                                       angiovalue = Data.angio(max(round(pos1(3)),1),round(pos1(2)),round(pos1(1)));
%                                       Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 250*(angiovalue-min(Data.angio(:)))/(max(Data.angio(:))-min(Data.angio(:)));
% %                                       Data.angioVolume(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
% %                                       idx1 = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
% %                                       Data.angioVolume(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
%                                       %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
%                                       %     angio(Z,Y,X) = 254;
% %                                       if isfield(Data,'node1')
% %                                           Data = rmfield(Data,'node1');
% %                                       end
%                                   end
%                               end
%                           end
% %                           epts = Data.Graph.edges(eidx(u),:);
% %                           epts = setdiff(epts,path(u));
%                     end
%                 end
% 
% %                  if isfield(Data.Graph,'verifiedEdges')
% %                      Data.Graph.verifiedEdges(idx) = [];
% %                      nodes = Data.Graph.nodes;
% %                      edges = Data.Graph.edges;
% %                      if get(handles.radiobutton_fastDisplay,'Value')
% %                          edgetemp  = Data.Graph.edges(end,:);
% %                          pos0 = max(nodes(edgetemp(1),:),1);
% %                          pos1 = max(nodes(edgetemp(2),:),1);
% %                          rsep = norm(pos1-pos0);
% %                          if rsep>0
% %                              cxyz = (pos1-pos0) / rsep;
% %                              rstep = 0;
% %                              pos = pos0;
% %                              while rstep<rsep
% %                                  %   im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
% %                                  angiovalue = Data.angio(max(round(pos(3)),1),round(pos(2)),round(pos(1)));
% %                                  Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 250*(angiovalue-min(Data.angio(:)))/(max(Data.angio(:))-min(Data.angio(:)));
% %                                  [max(round(pos(3)),1) round(pos(2)) round(pos(1))]
% %                                  pos = pos + cxyz*0.5;
% %                                  %if pos(1)<2 & pos(2)<2
% %                                  %    keyboard
% %                                  %end
% %                                  rstep = rstep + 0.5;
% %                              end
% %                          end
% %                          idx1 = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
% %                          Data.angioVolume(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
% %                          idx1 = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
% %                          Data.angioVolume(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
% %                          %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
% %                          %     angio(Z,Y,X) = 254;
% %                      end
% %                  end
%                  Data.Graph = rmfield(Data.Graph,'node1');
%              end
%          end
%     end  
elseif get(handles.radiobutton_unvalidateNodes,'Value') == 1
    
    if ~isfield(Data.Graph,'verifiedNodes')
        Data.Graph.verifiedNodes = zeros(size(Data.Graph.nodes,1),1);
    end
    if ~isfield(Data.Graph,'verifiedEdges')
        Data.Graph.verifiedEdges = zeros(size(Data.Graph.edges,1),1);
    end
    
    % find the indices close to the selected point
    s = 5;
    idx = find(Data.Graph.nodes(:,2) >= x-s & Data.Graph.nodes(:,2) <= x+s ...
            & Data.Graph.nodes(:,1) >= y-s & Data.Graph.nodes(:,1) <= y+s ...
            & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
    
    % find the closet point
    min_idx = 1;
    for u = 1:length(idx)
        idx_x = Data.Graph.nodes(idx(u),2);
        idx_y = Data.Graph.nodes(idx(u),1);
        if u == 1
            min_dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
        else
            dist = sqrt((idx_x-x)^2+(idx_y-y)^2);
            if dist < min_dist
                min_dist = dist;
                min_idx = u;
            end
        end
    end
     
    if ~isempty(idx)    
        if strcmp(mouseclick,'normal')
    %         idx = find(Data.Graph.nodes(:,2) >= x-1 & Data.Graph.nodes(:,2) <= x+1 ...
    %             & Data.Graph.nodes(:,1) >= y-1 & Data.Graph.nodes(:,1) <= y+1 ...
    %             & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
            if isfield(Data,'node1')
                tempnode = Data.node1;
            end
            Data.node1 = idx(min_idx);
            Data.Graph.verifiedNodes(idx(min_idx)) = 2;
            if get(handles.radiobutton_fastDisplay,'Value')  
                if exist('tempnode','var')
                    pos = Data.Graph.nodes(tempnode,:);
                    Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 254;
                end
                pos = Data.Graph.nodes(Data.node1,:);
                Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 251;
            end
        elseif strcmp(mouseclick,'alt')
    %        idx = find(Data.Graph.nodes(:,2) >= x-1 & Data.Graph.nodes(:,2) <= x+1 ...
    %             & Data.Graph.nodes(:,1) >= y-1 & Data.Graph.nodes(:,1) <= y+1 ...
    %             & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
            Data.node2 = idx(min_idx);
            if isfield(Data,'node1')
                if length(Data.node1) == 1
                    nlst = [];
                    cnode = Data.node1;
                    path = cnode;
                    pathtemp = [];
                    branchidx = 0;
                    count =0;
                    maxbranch = 3;
                    while(count < 1000) 
                        count = count + 1
        %                 [costs,paths] = dijkstra(Data.Graph.nodes,Data.Graph.edges,Data.node1,Data.node2,1);
                        eidx = find(Data.Graph.edges(:,1) == cnode | Data.Graph.edges(:,2) == cnode);
                        nidx = [];
                        for u = 1:length(eidx)
                            nidx = [nidx Data.Graph.edges(eidx(u),:)];
                        end
                        nidx = setdiff(nidx, path);
                        if length(nidx) > 1
                            branchidx = branchidx+1;
                            temp = [nidx(2:end)' branchidx*ones(size(nidx(2:end)'))];
                            if branchidx < maxbranch+1
    %                             nlst = [nlst nidx(2:end)];
                                nlst = [nlst; temp];
                                pathtemp = [pathtemp length(path)];
                                cnode = nidx(1);
                                path = [path cnode];
                            end
                        elseif length(nidx) == 1
                            cnode = nidx(1);
                            path = [path cnode];
                        end
    %                     if branchidx > maxbranch
    %                          cnode = nlst(end-1);
    %                     end
                        if (isempty(nidx) || branchidx > maxbranch+1) 
                            if ~isempty(nlst)
                                cnode = nlst(end,1);
                                if length(pathtemp) > 0
                                    path(pathtemp(end)+1:end) = [];
                                    pathtemp(end) = [];
                                end
                                branchidx = nlst(end,2);
                                nlst(end,:) = [];
                                path = [path cnode];
    %                             branchidx = max(0,branchidx - 1);
                            else
                                path = [];
                                break;
                            end
                        end 
                        if ~isempty(find(ismember(nidx,Data.node2)))
                            break;
                        end
    %                      if ~isempty(path)
    %                         Data.Graph.verifiedNodes(path) = 1;
    %                         Data.Graph.verifiedNodes(end) = 2;
    %                     end
    %                     draw(hObject, eventdata, handles);
                    end
                end
                if ~isempty(path)
                    Data.Graph.verifiedNodes(path) = 0;
%                     Data.Graph.verifiedNodes(Data.Graph.verifiedNodes ~= 0) = 1;
                    Data.Graph.verifiedNodes(path(end)) = 0;
                    Data.node1 = Data.node2;
                    for u = 1:length(path)-1
%                         idx = find(Data.Graph.edges(:,1) == path(u) & Data.Graph.edges(:,1) == path(u+1))
%                         Data.Graph.verifiedEdges(idx) = 1;
                          idx = find(Data.Graph.edges(:,1) == path(u) | Data.Graph.edges(:,2) == path(u));
                          for v = 1:length(idx) 
                              pt = setdiff(Data.Graph.edges(idx(v),:),path(u));
                              if ismember(pt,path)
                                  nodes = Data.Graph.nodes;
                                  edges = Data.Graph.edges;
                                  Data.Graph.verifiedEdges(idx(v)) = 0;
                                  if get(handles.radiobutton_fastDisplay,'Value')
                                      edgetemp  = Data.Graph.edges(idx(v),:);
                                      pos0 = max(nodes(edgetemp(1),:),1);
                                      pos1 = max(nodes(edgetemp(2),:),1);
                                      rsep = norm(pos1-pos0);
                                      if rsep>0
                                          cxyz = (pos1-pos0) / rsep;
                                          rstep = 0;
                                          pos = pos0;
                                          while rstep<rsep
                                              %             im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
                                              angiovalue = Data.angio(max(round(pos(3)),1),round(pos(2)),round(pos(1)));
%                                               Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 250*(angiovalue-min(Data.angio(:)))/(max(Data.angio(:))-min(Data.angio(:)));
                                              Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 252+1*Data.Graph.verifiedEdges(idx(v));
                                              pos = pos + cxyz*0.5;
                                              %if pos(1)<2 & pos(2)<2
                                              %    keyboard
                                              %end
                                              rstep = rstep + 0.5;
                                          end
                                      end
                                      idx1 = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
                                      Data.angioVolume(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
                                      idx1 = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
                                      Data.angioVolume(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx1(1));
                                      %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
                                      %     angio(Z,Y,X) = 254;
%                                       if isfield(Data,'node1')
%                                           Data = rmfield(Data,'node1');
%                                       end
                                  end
                              end
                          end
%                           epts = Data.Graph.edges(eidx(u),:);
%                           epts = setdiff(epts,path(u));
                    end
                end
            end
        end
    end
end
draw(hObject, eventdata, handles);



% function Node_ButtonDown(hObject, eventdata, handles)
% 
% global Data
% 
% if get(handles.checkbox_validateNodes,'Value') == 1
%     parent = (get(hObject, 'Parent'));
%     pts = round(get(parent, 'CurrentPoint'));
%     y = pts(1,1);
%     x = pts(1,2);
%     [Sz,Sx,Sy] = size(Data.angio);
%     Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
%     Zstartframe = min(max(Zstartframe,1),Sz);
%     ZMIP = str2double(get(handles.edit_ZMIP,'String'));
%     Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
%     parent = get(parent,'parent');
%     mouseclick = get(parent, 'SelectionType');
%     if ~isfield(Data.Graph,'verifiedNodes')
%         Data.Graph.verifiedNodes = zeros(size(Data.Graph.nodes,1),1);
%     end
%     if strcmp(mouseclick,'normal')
%         idx = find(Data.Graph.nodes(:,2) >= x-1 & Data.Graph.nodes(:,2) <= x+1 ...
%             & Data.Graph.nodes(:,1) >= y-1 & Data.Graph.nodes(:,1) <= y+1 ...
%             & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
%         Data.node1 = idx(1);
%         Data.Graph.verifiedNodes(idx(1)) = 2;
%     elseif strcmp(mouseclick,'alt')
%        idx = find(Data.Graph.nodes(:,2) >= x-1 & Data.Graph.nodes(:,2) <= x+1 ...
%             & Data.Graph.nodes(:,1) >= y-1 & Data.Graph.nodes(:,1) <= y+1 ...
%             & Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe);
%         Data.node2 = idx(1);
%         if isfield(Data,'node1')
%             if length(Data.node1) == 1
%                 nlst = [];
%                 cnode = Data.node1;
%                 path = cnode;
%                 pathtemp = [];
%                 branchidx = 0;
%                 count =0;
%                 maxbranch = 3;
%                 while(count < 1000) 
%                     count = count + 1
%     %                 [costs,paths] = dijkstra(Data.Graph.nodes,Data.Graph.edges,Data.node1,Data.node2,1);
%                     eidx = find(Data.Graph.edges(:,1) == cnode | Data.Graph.edges(:,2) == cnode);
%                     nidx = [];
%                     for u = 1:length(eidx)
%                         nidx = [nidx Data.Graph.edges(eidx(u),:)];
%                     end
%                     nidx = setdiff(nidx, path);
%                     if length(nidx) > 1
%                         branchidx = branchidx+1;
%                         temp = [nidx(2:end)' branchidx*ones(size(nidx(2:end)'))];
%                         if branchidx < maxbranch+1
% %                             nlst = [nlst nidx(2:end)];
%                             nlst = [nlst; temp];
%                             pathtemp = [pathtemp length(path)];
%                             cnode = nidx(1);
%                             path = [path cnode];
%                         end
%                     elseif length(nidx) == 1
%                         cnode = nidx(1);
%                         path = [path cnode];
%                     end
% %                     if branchidx > maxbranch
% %                          cnode = nlst(end-1);
% %                     end
%                     if (isempty(nidx) || branchidx > maxbranch+1) 
%                         if ~isempty(nlst)
%                             cnode = nlst(end,1);
%                             if length(pathtemp) > 0
%                                 path(pathtemp(end)+1:end) = [];
%                                 pathtemp(end) = [];
%                             end
%                             branchidx = nlst(end,2);
%                             nlst(end,:) = [];
%                             path = [path cnode];
% %                             branchidx = max(0,branchidx - 1);
%                         else
%                             path = [];
%                             break;
%                         end
%                     end 
%                     if ~isempty(find(ismember(nidx,Data.node2)))
%                         break;
%                     end
% %                      if ~isempty(path)
% %                         Data.Graph.verifiedNodes(path) = 1;
% %                         Data.Graph.verifiedNodes(end) = 2;
% %                     end
% %                     draw(hObject, eventdata, handles);
%                 end
%             end
%             if ~isempty(path)
%                 Data.Graph.verifiedNodes(path) = 1;
%                 Data.Graph.verifiedNodes(Data.Graph.verifiedNodes ~= 0) = 1;
%                 Data.Graph.verifiedNodes(path(end)) = 2;
%                 Data.node1 = Data.node2;
%             end
%         end
%     end
% end
% draw(hObject, eventdata, handles);

function addSegment(hObject, eventdata, handles)

global Data

draw(hObject, eventdata, handles)
answer = questdlg('Are you sure you want to add the segment?', 'Add segment','No');
if strcmp(answer,'Yes')
    if isfield(Data.Graph,'addSegment') & ~isempty(Data.Graph.addSegment)
        n = size(Data.Graph.nodes,1);
        ns = size(Data.Graph.addSegment,1);
%         seg_length = length(Data.Graph.verifiedSegments);
%         n1 = find(Data.Graph.nodes(:,1) == Data.Graph.addSegment(1,1) & Data.Graph.nodes(:,2) == Data.Graph.addSegment(1,2) ...
%              & Data.Graph.nodes(:,2) == Data.Graph.addSegment(1,3));
%         n2 = find(Data.Graph.nodes(:,1) == Data.Graph.addSegment(end,1) & Data.Graph.nodes(:,2) == Data.Graph.addSegment(end,2) ...
%              & Data.Graph.nodes(:,2) == Data.Graph.addSegment(end,3));
        tempidx = (ismember(Data.Graph.segInfo.segEndNodes(:,1),Data.Graph.addSegmentSnode) | ismember(Data.Graph.segInfo.segEndNodes(:,2),Data.Graph.addSegmentSnode));
        idx = find(tempidx == 1);
        if isempty(idx)
            seg_no = Data.Graph.segInfo.nodeSegN(Data.Graph.addSegmentSnode);
            segEndNodes = Data.Graph.segInfo.segEndNodes(seg_no,:);
            segStartNode = segEndNodes(1);
            Edgesidx = find(Data.Graph.segInfo.edgeSegN(:,1) == seg_no);
            currentEdges = Data.Graph.edges(Edgesidx,:);
            [Ordered_edges,Ordered_nodes] = OrderEdgeNodes(segStartNode,currentEdges);
            idx = find(Ordered_nodes == Data.Graph.addSegmentSnode);
            seg_length = length(Data.Graph.verifiedSegments);
            Data.Graph.segInfo.nodeSegN(Ordered_nodes(idx+1:end)) = seg_length+1;
            idx1 = ismember(Data.Graph.edges(:,1),Ordered_edges(idx:end,1));
            idx2 = ismember(Data.Graph.edges(:,2),Ordered_edges(idx:end,2));
            tempidx = find((idx1 & idx2) == 1);
            Data.Graph.segInfo.edgeSegN(tempidx) = seg_length+1;
            Data.Graph.segInfo.segEndNodes(end+1,:) = [Data.Graph.addSegmentSnode segEndNodes(2)];
            Data.Graph.segInfo.segEndNodes(seg_no,:) = [segEndNodes(1) Data.Graph.addSegmentSnode];
            Data.Graph.segInfo.segPos(end+1,:) = [1 1 1];
%             Data.Graph.segInfo.segCGrps(end+1) = 1;
            Data.Graph.verifiedSegments(end+1) = Data.Graph.verifiedSegments(seg_no);
        end
        if isfield(Data.Graph,'addSegmentEnode')
            Data.Graph.nodes = [Data.Graph.nodes; Data.Graph.addSegment(2:end-1,:)];
            for u = 1:size(Data.Graph.addSegment,1)-1
                if u == 1
                    Data.Graph.edges(end+1,:) = [Data.Graph.addSegmentSnode n+u];
                elseif u == size(Data.Graph.addSegment,1)-1
                    Data.Graph.edges(end+1,:) = [n+u-1 Data.Graph.addSegmentEnode];
                else
                    Data.Graph.edges(end+1,:) = [n+u-1 n+u];
                end
            end
            seg_length = length(Data.Graph.verifiedSegments);
            Data.Graph.verifiedNodes(end+1:end+ns-2) = 1;
            Data.Graph.verifiedEdges(end+1:end+ns-1) = 1;
            Data.Graph.segInfo.nodeGrp(end+1:end+ns-2) = 1;
            Data.Graph.segInfo.nodeSegN(end+1:end+ns-2) = seg_length+1;
            Data.Graph.segInfo.segNedges(end+1) = ns-1;
            Data.Graph.segInfo.edgeSegN(end+1:end+ns-1) = seg_length+1;
            Data.Graph.segInfo.segEndNodes(end+1,:) = [Data.Graph.addSegmentSnode Data.Graph.addSegmentEnode];
            Data.Graph.segInfo.segPos(end+1,:) = [1 1 1];
            Data.Graph.segInfo.segCGrps(end+1) = 1;
            Data.Graph.verifiedSegments(end+1) = 1;
        else
            Data.Graph.nodes = [Data.Graph.nodes; Data.Graph.addSegment(2:end,:)];
            for u = 1:size(Data.Graph.addSegment,1)-1
                if u == 1
                    Data.Graph.edges(end+1,:) = [Data.Graph.addSegmentSnode n+u];
                else
                    Data.Graph.edges(end+1,:) = [n+u-1 n+u];
                end
            end
            seg_length = length(Data.Graph.verifiedSegments);
            Data.Graph.verifiedNodes(end+1:end+ns-1) = 1;
            Data.Graph.verifiedEdges(end+1:end+ns-1) = 1;
            Data.Graph.segInfo.nodeGrp(end+1:end+ns-1) = 1;
            Data.Graph.segInfo.nodeSegN(end+1:end+ns-1) = seg_length+1;
            Data.Graph.segInfo.segNedges(end+1) = ns-1;
            Data.Graph.segInfo.edgeSegN(end+1:end+ns-1) = seg_length+1;
            Data.Graph.segInfo.segEndNodes(end+1,:) = [Data.Graph.addSegmentSnode n+u];
            Data.Graph.segInfo.segPos(end+1,:) = [1 1 1];
%             Data.Graph.segInfo.segCGrps(end+1) = 1;
            Data.Graph.verifiedSegments(end+1) = 1;
        end
%         else
           
            
%             segNodes = find(Data.Graph.seginfo.nodeSegN == seg_no)
%             segNodes = unique(segEndnodes,segNodes);           
%             while(1)
%                 tempidx = find(Data.Graph.edges(:,1)==Data.Graph.addSegmentSnode | Data.Graph.edges(:,2)==Data.Graph.addSegmentSnode);
%                 connectedNodes = edges(tempidx,:);
%                 connectedNodes = intersect(connectedNodes(:),segNodes);
%                 
%             end
%         end
        if isfield(Data.Graph,'addSegment')
            Data.Graph = rmfield(Data.Graph,'addSegment');
        end
        if isfield(Data.Graph,'addSegmentSnode')
            Data.Graph = rmfield(Data.Graph,'addSegmentSnode');
        end
        if isfield(Data.Graph,'addSegmentEnode')
            Data.Graph = rmfield(Data.Graph,'addSegmentEnode');
        end
    end
else
    if isfield(Data.Graph,'addSegment')
        Data.Graph = rmfield(Data.Graph,'addSegment');
    end
    if isfield(Data.Graph,'addSegmentSnode')
        Data.Graph = rmfield(Data.Graph,'addSegmentSnode');
    end
     if isfield(Data.Graph,'addSegmentEnode')
        Data.Graph = rmfield(Data.Graph,'addSegmentEnode');
     end
end

function [Ordered_edges,Ordered_Nodes] = OrderEdgeNodes(segStartNode,currentEdges)
% 
Ordered_Nodes=[segStartNode];
Ordered_edges=[];
lastNode=segStartNode;
while ~isempty(currentEdges)
    connectedEdgesIndex=(find(currentEdges(:,1)==lastNode|currentEdges(:,2)==lastNode));
    connectedEdge=currentEdges(connectedEdgesIndex,:);
    newNode=setdiff(connectedEdge,lastNode);
    Ordered_Nodes=[Ordered_Nodes;newNode];
    Ordered_edges=[Ordered_edges;connectedEdge];
    lastNode=newNode;
    currentEdges(connectedEdgesIndex,:)=[];
end

function edit_Zstartframe_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Zstartframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Zstartframe as text
%        str2double(get(hObject,'String')) returns contents of edit_Zstartframe as a double
global Data

[z,x,y] = size(Data.angio);
ii = str2double(get(handles.edit_Zstartframe,'String'));
if isnan(ii)
    ii = Data.ZoomZrange(1);
    set(handles.edit_Zstartframe,'String',num2str(ii));
    return
end
ii = min(max(ii,1),z);
set(handles.edit_Zstartframe,'String',num2str(ii));
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_Zstartframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Zstartframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_XcenterZoom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_XcenterZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_XcenterZoom as text
%        str2double(get(hObject,'String')) returns contents of edit_XcenterZoom as a double
global Data
Xcenter = str2double(get(handles.edit_XcenterZoom,'String'));
XwidthZoom = str2double(get(handles.edit_XwidthZoom,'String'));
if isnan(Xcenter) || isnan(XwidthZoom)
    Xcenter = round((Data.ZoomXrange(1)+Data.ZoomXrange(2))/2);
    XwidthZoom = round((Data.ZoomXrange(2)-Data.ZoomXrange(1)+1));
    set(handles.edit_XcenterZoom,'String',num2str(Xcenter));
    set(handles.edit_XwidthZoom,'String',num2str(XwidthZoom));
    return
end
Data.ZoomXrange = [max((Xcenter-XwidthZoom/2),1) min((Xcenter+XwidthZoom/2),size(Data.angio,2))];
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_XcenterZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_XcenterZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_YcenterZoom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_YcenterZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_YcenterZoom as text
%        str2double(get(hObject,'String')) returns contents of edit_YcenterZoom as a double
global Data
Ycenter = str2double(get(handles.edit_YcenterZoom,'String'));
YwidthZoom = str2double(get(handles.edit_YwidthZoom,'String'));
if isnan(Ycenter) || isnan(YwidthZoom)
    Ycenter = round((Data.ZoomYrange(1)+Data.ZoomYrange(2))/2);
    YwidthZoom = round((Data.ZoomYrange(2)-Data.ZoomYrange(1)+1));
    set(handles.edit_YcenterZoom,'String',num2str(Ycenter));
    set(handles.edit_YwidthZoom,'String',num2str(YwidthZoom));
    return
end
Data.ZoomYrange = [max((Ycenter-YwidthZoom/2),1) min((Ycenter+YwidthZoom/2),size(Data.angio,2))];
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_YcenterZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_YcenterZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ZMIP_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ZMIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ZMIP as text
%        str2double(get(hObject,'String')) returns contents of edit_ZMIP as a double
global Data
ii = str2double(get(handles.edit_ZMIP,'String'));
if isnan(ii)
    ii = Data.ZoomZrange(2);
    set(handles.edit_ZMIP,'String',num2str(ii));
    return
end
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_ZMIP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ZMIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_XwidthZoom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_XwidthZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_XwidthZoom as text
%        str2double(get(hObject,'String')) returns contents of edit_XwidthZoom as a double
global Data
Xcenter = str2double(get(handles.edit_XcenterZoom,'String'));
XwidthZoom = str2double(get(handles.edit_XwidthZoom,'String'));
if isnan(Xcenter) || isnan(XwidthZoom)
    Xcenter = round((Data.ZoomXrange(1)+Data.ZoomXrange(2))/2);
    XwidthZoom = round((Data.ZoomXrange(2)-Data.ZoomXrange(1)+1));
    set(handles.edit_XcenterZoom,'String',num2str(Xcenter));
    set(handles.edit_XwidthZoom,'String',num2str(XwidthZoom));
    return
end
Data.ZoomXrange = [max((Xcenter-XwidthZoom/2),1) min((Xcenter+XwidthZoom/2),size(Data.angio,2))];

draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_XwidthZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_XwidthZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_YwidthZoom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_YwidthZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_YwidthZoom as text
%        str2double(get(hObject,'String')) returns contents of edit_YwidthZoom as a double
global Data
Ycenter = str2double(get(handles.edit_YcenterZoom,'String'));
YwidthZoom = str2double(get(handles.edit_YwidthZoom,'String'));
if isnan(Ycenter) || isnan(YwidthZoom)
    Ycenter = round((Data.ZoomYrange(1)+Data.ZoomYrange(2))/2);
    YwidthZoom = round((Data.ZoomYrange(2)-Data.ZoomYrange(1)+1));
    set(handles.edit_YcenterZoom,'String',num2str(Ycenter));
    set(handles.edit_YwidthZoom,'String',num2str(YwidthZoom));
    return
end
Data.ZoomYrange = [max((Ycenter-YwidthZoom/2),1) min((Ycenter+YwidthZoom/2),size(Data.angio,2))];

draw(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_YwidthZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_YwidthZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Zmoveleft.
function pushbutton_Zmoveleft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Zmoveleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ii = str2double(get(handles.edit_Zstartframe,'String'));
ii = ii-1;
set(handles.edit_Zstartframe,'String',num2str(ii));
draw(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_Xmoveleft.
function pushbutton_Xmoveleft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Xmoveleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
ii = str2double(get(handles.edit_XcenterZoom,'String'));
XwidthZoom = str2double(get(handles.edit_XwidthZoom,'String'));
ii = ii-round(XwidthZoom*.10);
ii = min(max(ii,round(XwidthZoom/2)),size(Data.angio,2)-round(XwidthZoom/2));
set(handles.edit_XcenterZoom,'String',num2str(ii));
Xcenter = str2double(get(handles.edit_XcenterZoom,'String'));
XwidthZoom = str2double(get(handles.edit_XwidthZoom,'String'));
% Data.ZoomXrange = [max((Xcenter-XwidthZoom/2),1) min((Xcenter+XwidthZoom/2),size(Data.angio,2))];
draw(hObject, eventdata, handles);

% --- Executes on button press in pushbutton_Ymoveleft.
function pushbutton_Ymoveleft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Ymoveleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
ii = str2double(get(handles.edit_YcenterZoom,'String'));
YwidthZoom = str2double(get(handles.edit_YwidthZoom,'String'));
ii = ii-round(YwidthZoom*.10);
ii = min(max(ii,round(YwidthZoom/2)),size(Data.angio,3)-round(YwidthZoom/2));
set(handles.edit_YcenterZoom,'String',num2str(ii));
Ycenter = str2double(get(handles.edit_YcenterZoom,'String'));
% Data.ZoomYrange = [max((Ycenter-YwidthZoom/2),1) min((Ycenter+YwidthZoom/2),size(Data.angio,2))];
draw(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_Zmoveright.
function pushbutton_Zmoveright_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Zmoveright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ii = str2double(get(handles.edit_Zstartframe,'String'));
ii = ii+1;
set(handles.edit_Zstartframe,'String',num2str(ii));
draw(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_Xmoveright.
function pushbutton_Xmoveright_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Xmoveright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
ii = str2double(get(handles.edit_XcenterZoom,'String'));
XwidthZoom = str2double(get(handles.edit_XwidthZoom,'String'));
ii = ii+round(XwidthZoom*.10);
ii = min(max(ii,round(XwidthZoom/2)),size(Data.angio,2)-round(XwidthZoom/2));
set(handles.edit_XcenterZoom,'String',num2str(ii));
Xcenter = str2double(get(handles.edit_XcenterZoom,'String'));
XwidthZoom = str2double(get(handles.edit_XwidthZoom,'String'));
% Data.ZoomXrange = [max((Xcenter-XwidthZoom/2),1) min((Xcenter+XwidthZoom/2),size(Data.angio,2))];
draw(hObject, eventdata, handles);

% --- Executes on button press in pushbutton_Ymoveright.
function pushbutton_Ymoveright_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Ymoveright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
ii = str2double(get(handles.edit_YcenterZoom,'String'));
YwidthZoom = str2double(get(handles.edit_YwidthZoom,'String'));
ii = ii+round(YwidthZoom*.10);
ii = min(max(ii,round(YwidthZoom/2)),size(Data.angio,3)-round(YwidthZoom/2));
set(handles.edit_YcenterZoom,'String',num2str(ii));
Ycenter = str2double(get(handles.edit_YcenterZoom,'String'));
% Data.ZoomYrange = [max((Ycenter-YwidthZoom/2),1) min((Ycenter+YwidthZoom/2),size(Data.angio,2))];
draw(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Filters_Callback(hObject, eventdata, handles)
% hObject    handle to Filters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Filters_GausFilter_Callback(hObject, eventdata, handles)
% hObject    handle to Filters_GausFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
prompt = {'Please enter sigma for Gaussian Filter'};
defaultans = {'2'};
x = inputdlg(prompt,'Gaussian Filter',1,defaultans);
sigma = str2double(x{1});
if isfield(Data,'angioF')
    I = Data.angioF;
else
    I = Data.angio;
end
h = waitbar(0,'Please wait... applying gaussian filter');
Data.angioF = imgaussfilt3(I,sigma);
if isfield(Data,'procSteps')
    Data.procSteps(end+1,:) =  {{'Gaussian Filter'},{'Sigma'},{sigma}};
else
    Data.procSteps = {{'Gaussian Filter'},{'Sigma'},{sigma}};
end
waitbar(1);
close(h);
draw(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Filters_MedFilter_Callback(hObject, eventdata, handles)
% hObject    handle to Filters_MedFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
prompt = {'Enter filter size in Z :','Enter filter size in X :','Enter filter size in Y :'};
defaultans = {'3','3','3'};
x = inputdlg(prompt,'Filter Size',1,defaultans );
sz = str2double(x{1});
sx = str2double(x{2});
sy = str2double(x{3});
if isfield(Data,'angioF')
    I = Data.angioF;
else
    I = Data.angio;
end
h = waitbar(0,'Please wait... applying Median filter');
Data.angioF = medfilt3(I,[sz sx sy]);
if isfield(Data,'procSteps')
    Data.procSteps(end+1,:) =  {{'Median Filter'},{'Size'},{[sz sx sy]}};
else
    Data.procSteps =  {{'Median Filter'},{'Size'},{[sz sx sy]}};
end
waitbar(1);
close(h);
draw(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Filters_TubenessFilter_Callback(hObject, eventdata, handles)
% hObject    handle to Filters_TubenessFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
h = waitbar(0,'Please wait... applying Tubeness filter');

if isfield(Data,'angioF')
    I = Data.angioF;
else
    I = Data.angio;
end
I = double(I);
% Z = size(I,3);
% beta = 100;
% c = 500;
[k,l,m] = size(I);
% [nz,nx,ny] = size(I);
% L   = zeros(k,l,m);
% Vs  = zeros(k,l,m);
alpha = 0.25;
gamma12 = 0.5;
gamma23 = 0.5;
T = zeros(k,l,m);
prompt = {'Enter Gaussian filter start value :','Enter Gaussian filter end value :','Enter Gaussian filter step size :'};
defaultans = {'2','3','1'};
x = inputdlg(prompt,'Tubeness filter parameters',1,defaultans );
sigma = str2double(x{1}):str2double(x{3}):str2double(x{2});
for i = 1:length(sigma)

    waitbar((i-1)/length(sigma));
    [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(I,sigma(i));

%     Normalizing the Hessian Matrix
    Dxx = sigma(i)^2*Dxx; Dyy = sigma(i)^2*Dyy;  Dzz = sigma(i)^2*Dzz; Dxy = sigma(i)^2*Dxy;  Dxz = sigma(i)^2*Dxz; Dyz = sigma(i)^2*Dyz;



    [Lambda1,Lambda2,Lambda3,~,~,~] = eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);


    SortL = sort([Lambda1(:)'; Lambda2(:)'; Lambda3(:)'],'descend');
    Lambda1 = reshape(SortL(1,:),size(Lambda1));
    Lambda2 = reshape(SortL(2,:),size(Lambda2));
    Lambda3 = reshape(SortL(3,:),size(Lambda3));

    idx = find(Lambda3 < 0 & Lambda2 < 0 & Lambda1 < 0);
    T(idx ) = abs(Lambda3(idx)).*(Lambda2(idx)./Lambda3(idx)).^gamma23.*(1+Lambda1(idx)./abs(Lambda2(idx))).^gamma12;
    idx = find(Lambda3 < 0 & Lambda2 < 0 & Lambda1 > 0 & Lambda1 < abs(Lambda2)/alpha);
    T(idx ) = abs(Lambda3(idx)).*(Lambda2(idx)./Lambda3(idx)).^gamma23.*(1-alpha*Lambda1(idx)./abs(Lambda2(idx))).^gamma12;

    %         L1 = (2*Lambda1-Lambda2-Lambda3)./(2*sqrt(Lambda1.^2+Lambda2.^2+Lambda3.^2-Lambda1.*Lambda2-Lambda1.*Lambda3-Lambda2.*Lambda3));
    %         L1 = exp(-alpha*(L1-1).^2);
    %         L1(abs(Lambda1)> abs(Lambda2)) = 0;
    %         L1(Lambda2>0 | Lambda3>0) = 0;
    %         L1 = -L1.*Lambda2;
    %         L = max(L,L1);
    %
    %         Ra = abs(Lambda2./Lambda3);
    %         Rb = abs(Lambda1./(Lambda2.*Lambda3));
    %         s = sqrt(Lambda1.^2+Lambda2.^2+Lambda3.^2);
    %         Vs1 = 1-exp(-Ra.^2/(2*alpha)).*exp(-Rb.^2/(2*beta)).*(1-exp(-s.^2/(2*c)));
    %         Vs1(Lambda2>0 | Lambda3>0) = 0;
    %         Vs1(abs(Lambda1) > abs(Lambda2)) = 0;
    %         Vs = max(Vs,Vs1);
%     [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(T,sigma(i));
%     % Normalizing the Hessian Matrix
%      Dxx = sigma(i)^2*Dxx; Dyy = sigma(i)^2*Dyy;  Dzz = sigma(i)^2*Dzz; Dxy = sigma(i)^2*Dxy;  Dxz = sigma(i)^2*Dxz; Dyz = sigma(i)^2*Dyz;
% 
%     [Lambda1,Lambda2,Lambda3,V1,V2,V3] = eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
% 
%     SortL = sort([Lambda1(:)'; Lambda2(:)'; Lambda3(:)'],'ascend');
%     Lambda1 = reshape(SortL(1,:),size(Lambda1));
%     Lambda2 = reshape(SortL(2,:),size(Lambda2));
%     Lambda3 = reshape(SortL(3,:),size(Lambda3));
% 
%     E = -sigma(i)^2.*Lambda2;
%     E(E<0) = 0;
%     if i == 1
%         Emax = E;
%     else
%         Emax = max(E,Emax);
%     end
    if i == 1
        Emax = T;
    else
        Emax = max(T,Emax);
    end

end
%     T = L;
T = Emax;

T = (T-min(T(:)))/(max(T(:))-min(T(:)));
Data.angioT = T;
if isfield(Data,'procSteps')
    Data.procSteps(end+1,:) =  {{'Tubeness Filter'},{'Sigma'},{sigma}};
else
    Data.procSteps =  {{'Tubeness Filter'},{'Sigma'},{sigma}};
end
close(h);
draw(hObject, eventdata, handles);



% --------------------------------------------------------------------
function Filters_ResetFilter_Callback(hObject, eventdata, handles)
% hObject    handle to Filters_ResetFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

if isfield(Data,'angioF')
    Data = rmfield(Data,'angioF');
end

if isfield(Data,'angioT')
    Data = rmfield(Data,'angioT');
end

if isfield(Data,'segangio')
    Data = rmfield(Data,'segangio');
end

if isfield(Data,'procSteps')
    Data = rmfield(Data,'procSteps');
end
draw(hObject, eventdata, handles);

% --------------------------------------------------------------------
function File_savedata_Callback(hObject, eventdata, handles)
% hObject    handle to File_savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Data
% if isfield(Data,'angioF')|| isfield(Data,'angioT') || isfield(Data,'segangio') || isfield(Data,'angioVolume')
    if isfield(Data,'rawdatapath')
        Output.rawdatapath = Data.rawdatapath;
    end
    if isfield(Data,'angioVolume')
        Output.angioVolume = int16(Data.angioVolume);
    end
    if isfield(Data,'procSteps')
        Output.procSteps = Data.procSteps;
    end
    if isfield(Data,'angioF')
        Output.angioF = Data.angioF;
    end
    if isfield(Data,'angioT')
        Output.angioT = Data.angioT;
    end
    if isfield(Data,'segangio')
        Output.segangio = Data.segangio;
    end
    if isfield(Data,'fv')
        Output.fv = Data.fv;
    end
    if isfield(Data,'Graph')
        Output.Graph = Data.Graph;
    end
    if isfield(Data,'notes')
        Output.notes = Data.notes;
    end
    [FileName,PathName] = uiputfile('*.mat');
    h = waitbar(0,'Please wait... saving the data');
    save([PathName FileName],'Output');
    waitbar(1);
    close(h);
% end





% --------------------------------------------------------------------
function Segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to Segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function segmentation_thresholding_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_thresholding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
% Check if angioT exists before segmentation
% if isfield(Data,'angioT')
    prompt = {'Please enter threshold value for segmentation'};
    defaultans = {'0.05'};
    x = inputdlg(prompt,'Segmenatation',1,defaultans);
    threshold = str2double(x{1});
    h = waitbar(0,'Please wait... saving the data');
    T = Data.angioT;
%     T = (T-min(T(:)))/(max(T(:))-min(T(:)));
%         T = Data.angioF;
    T_seg = zeros(size(T));
    idx = find(T > threshold);
    T_seg(idx) = 1;
    CC = bwconncomp(T_seg);
    T_segM = T_seg;
    for uuu = 1:length(CC.PixelIdxList)
         if length(CC.PixelIdxList{uuu}) < 100
             T_segM(CC.PixelIdxList{uuu}) = 0;
         end
    end
    Data.segangio = T_segM == 1;
    if isfield(Data,'procSteps')
        Data.procSteps(end+1,:) =  {{'Thresholding on tubeness filter'},{'Threshold value'},{threshold}};
    else
        Data.procSteps =  {{'Thresholding on tubeness filter'},{'Threshold value'},{threshold}};
    end
    waitbar(1);
    close(h);
% end

draw(hObject, eventdata, handles);




% --------------------------------------------------------------------
function segmentation_SeedBasedSegmentation_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_SeedBasedSegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
addpath(genpath([pwd '\seed_based_segmentation']));

% Check if angioT exists before segmentation
use_segmentation_as_fg_seeds = 0;
if isfield(Data,'segangio')
    choice = questdlg('Use the existing segmentation as foreground seeds?',...
                      'Seed selection','Yes','No','Cancel','Yes');
    switch choice
      case 'Cancel'
        return
      case 'No'
        use_segmentation_as_fg_seeds = 0;
      case 'Yes'
       use_segmentation_as_fg_seeds = 1;
    end
end

if use_segmentation_as_fg_seeds
    options.fg_seed_vol = Data.segangio;
    prompt = {'Background seed percentage :','Background seed window size :','Region size (voxels on a side) :'};
    defaultans = {'50', '75', '50'};
    x = inputdlg(prompt,'Seed-based segmentation parameters',1,defaultans );
    options.bg_percentage = str2double(x{1});
    options.bg_win = str2double(x{2});
    options.region_size = str2double(x{3});
else
    prompt = {'Foreground seed percentage :','Foreground seed window size :','Background seed percentage :','Background seed window size :','Region size (voxels on a side) :'};
    defaultans = {'1', '300', '50', '75', '50'};
    x = inputdlg(prompt,'Seed-based segmentation parameters',1,defaultans );
    options.fg_percentage = str2double(x{1});
    options.fg_win = str2double(x{2});
    options.bg_percentage = str2double(x{3});
    options.bg_win = str2double(x{4});
    options.region_size = str2double(x{5});
end

if isfield(Data,'angioF')
    input = Data.angioF;
else
    input = Data.angio;
end

options.progress = 1;
[seg_vol, seg_prob, fg_seed_vol, bg_seed_vol] = segment_vessels_random_walker(input, options);
Data.segangio = seg_vol;
Data.fg_seed_vol = fg_seed_vol;
Data.bg_seed_vol = bg_seed_vol;
if isfield(Data,'procSteps')
    Data.procSteps(end+1,:) =  {{'Seed-based segmentation'},{'Options'},{options}};
else
    Data.procSteps =  {{'Seed-based segmentation'},{'Options'},{options}};
end

% --- Executes on button press in pushbutton_Zoomin.
function pushbutton_Zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
set(handles.radiobutton_validateNodes,'Enable','off');
set(handles.radiobutton_addEdge,'Enable','off');
set(handles.radiobutton_selectSegment,'Enable','off');
draw(hObject, eventdata, handles);
axes(handles.axes1)
title('\fontsize{16}\color{red}ZOOM IN');
k = waitforbuttonpress;
if k==0
    point1 = get(handles.axes1,'CurrentPoint');     % button down detected
    finalRect = rbbox;                              % return figure units
    point2 = get(handles.axes1,'CurrentPoint');     % button up detected
    point1 = round(point1(1,1:2));                  % extract x and y
    point2 = round(point2(1,1:2));

%     if isfield(cna,'ROIs')
%         cna.ROIs(end+1,:,:,:) = [point1; point2; [zrange(1) zrange(end)]];
%     else
%         cna.ROIs(1,:,:,:) = [point1; point2;[zrange(1) zrange(end)]];
%     end
%     draw(hObject, eventdata, handles);
% Data.ZoomYrange = [point1(2) point2(2)];
% Data.ZoomXrange = [point1(1) point2(1)];
Data.ZoomYrange = [min(point1(2),point2(2)) max(point1(2),point2(2))];
Data.ZoomXrange = [min(point1(1),point2(1)) max(point1(1),point2(1))];
set(handles.edit_XcenterZoom,'String',num2str(mean([point1(1) point2(1)-1])));
set(handles.edit_YcenterZoom,'String',num2str(mean([point1(2) point2(2)-1])));
set(handles.edit_XwidthZoom,'String',num2str(point2(1)-point1(1)+1));
set(handles.edit_YwidthZoom,'String',num2str(point2(2)-point1(2)+1));
end
% rect_pos = rbbox;
set(handles.radiobutton_validateNodes,'Enable','on');
set(handles.radiobutton_addEdge,'Enable','on');
set(handles.radiobutton_selectSegment,'Enable','on');
draw(hObject, eventdata, handles);



% --- Executes on button press in pushbutton_ZoomOut.
function pushbutton_ZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
Data.ZoomYrange = [1 size(Data.angio,3)];
Data.ZoomXrange = [1 size(Data.angio,2)];
set(handles.edit_XcenterZoom,'String',num2str(mean([1 size(Data.angio,2)-1])))
set(handles.edit_YcenterZoom,'String',num2str(mean([1 size(Data.angio,3)-1])))
set(handles.edit_XwidthZoom,'String',num2str(size(Data.angio,2)));
set(handles.edit_YwidthZoom,'String',num2str(size(Data.angio,2)));
draw(hObject, eventdata, handles);


% % --- Executes on button press in pushbutton_displayMesh.
% function pushbutton_displayMesh_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton_displayMesh (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% global Data
% wait_h = waitbar(0,'Please wait... calculating the mesh');
% if isfield(Data,'segangio')
%     Mask = permute(Data.segangio,[2 3 1]);
%     if isfield(Data,'fv')
%         fv2 = Data.fv;
%     else
%         fv = isosurface(Mask);
%         fv2 = reducepatch(fv,200000);
%     end
% 
% %     fv2 = fv;
%     f = fv2.faces;
%     v = fv2.vertices;
%     figure(2);
%     clf
% 
%     h=trisurf(f,v(:,1),v(:,2),v(:,3),'facecolor','red','edgecolor','none');
%     daspect([1,1,1])
%     view(3); axis tight
%     camlight
%     lighting gouraud
%     xlabel('Y')
%     ylabel('X')%     zlabel('Z')
%     Data.fv = fv2;
%     offset = [1,1,1];
%     save('mesh.mat','Mask','f','v','offset');
% end
% waitbar(1);
% close(wait_h);



function edit_imageInfo_Callback(hObject, eventdata, handles)
% hObject    handle to edit_imageInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_imageInfo as text
%        str2double(get(hObject,'String')) returns contents of edit_imageInfo as a double


% --- Executes during object creation, after setting all properties.
function edit_imageInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_imageInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkboxDisplayGraph.
function checkboxDisplayGraph_Callback(hObject, eventdata, handles)
draw(hObject, eventdata, handles)


% --- Executes on button press in pushbuttonRegraphNodes.
function pushbuttonRegraphNodes_Callback(hObject, eventdata, handles)
global Data
% global Data
if get(handles.checkbox_prcoessVisible,'Value') == 1
    [Sz,Sx,Sy] = size(Data.angio);
    Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
    Zstartframe = min(max(Zstartframe,1),Sz);
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
    Xstartframe = str2double(get(handles.edit_XcenterZoom,'String'));
    Xstartframe = min(max(Xstartframe,1),Sx);
    XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    Xendframe = min(max(Xstartframe+XMIP-1,1),Sx);
    Ystartframe = str2double(get(handles.edit_YcenterZoom,'String'));
    Ystartframe = min(max(Ystartframe,1),Sy);
    YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    Yendframe = min(max(Ystartframe+YMIP-1,1),Sy);
    
    idx = find(Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe ...
        & Data.Graph.nodes(:,1)>= Data.ZoomXrange(1) & Data.Graph.nodes(:,1) <= Data.ZoomXrange(2) ...
        & Data.Graph.nodes(:,2)>= Data.ZoomYrange(1) & Data.Graph.nodes(:,2) <= Data.ZoomYrange(2));
    [nodes, edges,verifiedNodes,verifiedEdges] = regraphNodes_new( Data.Graph.nodes, Data.Graph.edges,Data.Graph.verifiedNodes,idx);
    [nodes, edges,verifiedNodes,verifiedEdges] = fillNodes_new( nodes, edges, verifiedNodes,verifiedEdges,idx);
    Data.Graph.nodes = nodes;
    Data.Graph.edges = edges;
    Data.Graph.verifiedNodes = verifiedNodes;
    Data.Graph.verifiedEdges = verifiedEdges;
else
    if ~isfield(Data.Graph,'verifiedEdges')
        Data.Graph.verifiedEdges = zeros(size(Data.Graph.edges,1),1);
    end
    
    if ~isfield(Data.Graph,'verifiedNodes')
        Data.Graph.verifiedNodes = zeros(size(Data.Graph.nodes,1),1);
    end
    
    if ~isfield(Data.Graph,'verifiedSegments')
        Data.Graph.verifiedSegments = zeros(length(Data.Graph.segInfo.segLen),1);
    end
    [nodes, edges,verifiedNodes,verifiedEdges] = regraphNodes_new( Data.Graph.nodes, Data.Graph.edges,Data.Graph.verifiedNodes);
    [nodes, edges,verifiedNodes,verifiedEdges] = fillNodes_new( nodes, edges, verifiedNodes,verifiedEdges);
    Data.Graph.nodes = nodes;
    Data.Graph.edges = edges;
    Data.Graph.verifiedNodes = verifiedNodes;
    Data.Graph.verifiedEdges = verifiedEdges;
end
% end
draw(hObject, eventdata, handles)


% --- Executes on button press in pushbuttonStraightenNodes.
function pushbuttonStraightenNodes_Callback(hObject, eventdata, handles)
global Data

Ithresh = str2double(get(handles.edit_Ithresh,'String'));
if get(handles.checkbox_prcoessVisible,'Value') == 1
    [Sz,Sx,Sy] = size(Data.angio);
    Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
    Zstartframe = min(max(Zstartframe,1),Sz);
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
    Xstartframe = str2double(get(handles.edit_XcenterZoom,'String'));
    Xstartframe = min(max(Xstartframe,1),Sx);
    XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    Xendframe = min(max(Xstartframe+XMIP-1,1),Sx);
    Ystartframe = str2double(get(handles.edit_YcenterZoom,'String'));
    Ystartframe = min(max(Ystartframe,1),Sy);
    YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    Yendframe = min(max(Ystartframe+YMIP-1,1),Sy);
    
    idx = find(Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe ...
        & Data.Graph.nodes(:,1)>= Data.ZoomXrange(1) & Data.Graph.nodes(:,1) <= Data.ZoomXrange(2) ...
        & Data.Graph.nodes(:,2)>= Data.ZoomYrange(1) & Data.Graph.nodes(:,2) <= Data.ZoomYrange(2));
%     nodesNew = straightenNodes_modified( Data.Graph.nodes, Data.Graph.edges, permute(Data.segangio,[2 3 1]), 0.5,idx ); % permute to x,y,z
    nodesNew = straightenNodes_modified( Data.Graph.nodes, Data.Graph.edges, permute(Data.angio,[2 3 1]), Ithresh,Data.Graph.verifiedNodes,idx ); % permute to x,y,z
else

%     nodesNew = straightenNodes_modified( Data.Graph.nodes, Data.Graph.edges, permute(Data.segangio,[2 3 1]), 0.5 ); % permute to x,y,z
    nodesNew = straightenNodes_modified( Data.Graph.nodes, Data.Graph.edges, permute(Data.angio,[2 3 1]), Ithresh,Data.Graph.verifiedNodes ); % permute to x,y,z
end

Data.Graph.nodes = nodesNew;

draw(hObject, eventdata, handles)




% --------------------------------------------------------------------
function Filter_expTransformation_Callback(hObject, eventdata, handles)
% hObject    handle to Filter_expTransformation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

prompt = {'Enter transformation constant :'};
defaultans = {'4'};
Tc = str2double(inputdlg(prompt,'Transformation Constant',1,defaultans ));

if isfield(Data,'angioF')
    I = double(Data.angioF);
else
    I = double(Data.angio);
end

h = waitbar(0,'Please wait... applying Exponential Transform');

Data.angioF = 1-exp(-Tc*I/max(I(:)));

if isfield(Data,'procSteps')
    Data.procSteps(end+1,:) =  {{'Exponential Tranformation'},{'Transformation constant'},{Tc}};
else
    Data.procSteps =  {{'Exponential Tranformation'},{'Transformation constant'},{Tc}};
end
waitbar(1);
close(h);
draw(hObject, eventdata, handles);



% 
% % --- Executes on button press in pushbuttonGraphClear.
% function pushbuttonGraphClear_Callback(hObject, eventdata, handles)
% global Data
% 
% ch = questdlg('Do you want to clear the graph?','Yes','No');
% if strcmpi(ch,'No')
%     return;
% end
% 
% if exist('Data')
%     if isfield(Data,'Graph')
%         Data = rmfield(Data,'Graph');
%     end
% end
% 
% set(handles.checkboxDisplayGraph,'value',0);
% set(handles.checkboxDisplayGraph,'enable','off');
% 
% 
% draw(hObject, eventdata, handles)

% --- Executes on button press in pushbutton_moveNodestoCenter.
function pushbutton_moveNodestoCenter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_moveNodestoCenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

nodesNew = moveNodestoCenter( Data.Graph.nodes, Data.Graph.edges, permute(Data.segangio,[2 3 1]), 0.5 ); % permute to x,y,z

Data.Graph.nodes = nodesNew;

draw(hObject, eventdata, handles)



% --- Executes on button press in pushbutton_centerNodes.
function pushbutton_centerNodes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_centerNodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
if get(handles.checkbox_prcoessVisible,'Value') == 1
    [Sz,Sx,Sy] = size(Data.angio);
    Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
    Zstartframe = min(max(Zstartframe,1),Sz);
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
    Xstartframe = str2double(get(handles.edit_XcenterZoom,'String'));
    Xstartframe = min(max(Xstartframe,1),Sx);
    XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    Xendframe = min(max(Xstartframe+XMIP-1,1),Sx);
    Ystartframe = str2double(get(handles.edit_YcenterZoom,'String'));
    Ystartframe = min(max(Ystartframe,1),Sy);
    YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    Yendframe = min(max(Ystartframe+YMIP-1,1),Sy);
    
   idx = find(Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe ...
        & Data.Graph.nodes(:,1)>= Data.ZoomXrange(1) & Data.Graph.nodes(:,1) <= Data.ZoomXrange(2) ...
        & Data.Graph.nodes(:,2)>= Data.ZoomYrange(1) & Data.Graph.nodes(:,2) <= Data.ZoomYrange(2));
% idx = 1:size(Data.Graph.nodes,1);
%     
%     nodes = Data.Graph.nodes(idx,:);
    
    nodesNew = centerNodes_transversePlane( Data.Graph.nodes, Data.Graph.edges, Data.angio, Data.Graph.verifiedNodes, idx ); % permute to x,y,z
    
else
    nodesNew = centerNodes_transversePlane( Data.Graph.nodes, Data.Graph.edges, Data.angio,Data.Graph.verifiedNodes ); % permute to x,y,z
end

Data.Graph.nodes = nodesNew;

draw(hObject, eventdata, handles)



% --- Executes on button press in checkbox_prcoessVisible.
function checkbox_prcoessVisible_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_prcoessVisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_prcoessVisible



function edit_NodesInfo_Callback(hObject, eventdata, handles)
% hObject    handle to edit_NodesInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_NodesInfo as text
%        str2double(get(hObject,'String')) returns contents of edit_NodesInfo as a double


% --- Executes during object creation, after setting all properties.
function edit_NodesInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_NodesInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Meshing_meshAll_Callback(hObject, eventdata, handles)
% hObject    handle to Meshing_meshAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
wait_h = waitbar(0,'Please wait... calculating the mesh');
if isfield(Data,'segangio')
    Mask = permute(Data.segangio,[2 3 1]);
    if isfield(Data,'fv')
        fv2 = Data.fv;
    else
        fv = isosurface(Mask);
        fv2 = reducepatch(fv,200000);
    end

%     fv2 = fv;
    f = fv2.faces;
    v = fv2.vertices;
    figure(2);
    clf

    h=trisurf(f,v(:,1),v(:,2),v(:,3),'facecolor','red','edgecolor','none');
    daspect([1,1,1])
    view(3); axis tight
    camlight
    lighting gouraud
    xlabel('Y')
    ylabel('X')
    zlabel('Z')
    Data.fv = fv2;
    offset = [1,1,1];
    save('mesh.mat','Mask','f','v','offset');
end
waitbar(1);
close(wait_h);


% --------------------------------------------------------------------
function Meshing_meshVisible_Callback(hObject, eventdata, handles)
% hObject    handle to Meshing_meshVisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

wait_h = waitbar(0,'Please wait... calculating the mesh');
if isfield(Data,'segangio')
    [Sz,Sx,Sy] = size(Data.segangio);
    Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
    Zstartframe = min(max(Zstartframe,1),Sz);
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
    if isfield(Data,'ZoomXrange')
        Xstartframe = Data.ZoomXrange(1);
        Xendframe = Data.ZoomXrange(2);
    else
        Xstartframe = 1;
        Xendframe = Sx;
    end
     if isfield(Data,'ZoomYrange')
        Ystartframe = Data.ZoomYrange(1);
        Yendframe = Data.ZoomYrange(2);
    else
        Ystartframe = 1;
        Yendframe = Sy;
    end
        Mask = permute( Data.segangio(Zstartframe:Zendframe,Ystartframe:Yendframe,Xstartframe:Xendframe), [2 3 1]);
        fv = isosurface(Mask);
        fv2 = reducepatch(fv,200000);


%     fv2 = fv;
    f = fv2.faces;
    v = fv2.vertices;
    figure(2);
    clf

    if eventdata~=1
        h=trisurf(f,v(:,1),v(:,2),v(:,3),'facecolor','red','edgecolor','none');
        daspect([1,1,1])
        view(3); axis tight
        camlight
        lighting gouraud
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
    end

    offset = [Xstartframe,Ystartframe,Zstartframe];
    save('mesh.mat','Mask','f','v','offset');
end
waitbar(1);
close(wait_h);



% --------------------------------------------------------------------
function Meshing_graphMesh_Callback(hObject, eventdata, handles)
% hObject    handle to Meshing_graphMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load mesh.mat

graphTubularMesh( f, v, Mask, offset );


% --------------------------------------------------------------------
function Meshing_clearGraph_Callback(hObject, eventdata, handles)
% hObject    handle to Meshing_clearGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ch = questdlg('Do you want to clear the graph?','Yes','No');
if strcmpi(ch,'No')
    return;
end

if exist('Data')
    if isfield(Data,'Graph')
        Data = rmfield(Data,'Graph');
    end
end

set(handles.checkboxDisplayGraph,'value',0);
set(handles.checkboxDisplayGraph,'enable','off');


draw(hObject, eventdata, handles)



% --------------------------------------------------------------------
function Meshing_loadGraph_Callback(hObject, eventdata, handles)
% hObject    handle to Meshing_loadGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

[filename,pathname] = uigetfile({'*.mat'},'Please select the Graph Data to Load');
if filename==0
    return
end

load([pathname filename]);
% if ~exist('seg')
%     msgbox('Selected File does not have Graph information');
%     return
% end

%Data.Graph.seg = seg;
if isfield(Data,'Graph')
    nNodes = size(Data.Graph.nodes,1);
    nNewNodes = size(nodes,1);
    Data.Graph.nodes(nNodes+[1:nNewNodes],1:3) = nodes;

    nEdges = size(Data.Graph.edges,1);
    nNewEdges = size(edges,1);
    Data.Graph.edges(nEdges+[1:nNewEdges],1:2) = edges + nNodes;
else
    Data.Graph.nodes = nodes;
    Data.Graph.edges = edges;
end

set(handles.checkboxDisplayGraph,'enable','on')
draw(hObject, eventdata, handles)



% % --- Executes on button press in checkbox_validateNodes.
% function checkbox_validateNodes_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox_validateNodes (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of checkbox_validateNodes


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

global Data

keyPressed = eventdata.Key;
if strcmpi(keyPressed,'q')
    if get(handles.radiobutton_XYview,'Value')
        pushbutton_Zmoveleft_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_XZview,'Value')
        pushbutton_Ymoveleft_Callback(hObject, eventdata, handles)
    else
        pushbutton_Xmoveleft_Callback(hObject, eventdata, handles)
    end
elseif strcmpi(keyPressed,'e')
    if get(handles.radiobutton_XYview,'Value')
        pushbutton_Zmoveright_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_XZview,'Value')
        pushbutton_Ymoveright_Callback(hObject, eventdata, handles)
    else
        pushbutton_Xmoveright_Callback(hObject, eventdata, handles)
    end
elseif strcmpi(keyPressed,'a')
    if get(handles.radiobutton_XYview,'Value')
        pushbutton_Xmoveleft_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_XZview,'Value')
        pushbutton_Xmoveleft_Callback(hObject, eventdata, handles)
    else
        pushbutton_Ymoveright_Callback(hObject, eventdata, handles)
    end
elseif strcmpi(keyPressed,'d')
    if get(handles.radiobutton_XYview,'Value')
        pushbutton_Xmoveright_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_XZview,'Value')
        pushbutton_Xmoveright_Callback(hObject, eventdata, handles)
    else
        pushbutton_Ymoveleft_Callback(hObject, eventdata, handles)
    end
elseif strcmpi(keyPressed,'w')
    if get(handles.radiobutton_XYview,'Value')
        pushbutton_Ymoveleft_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_XZview,'Value')
        pushbutton_Zmoveleft_Callback(hObject, eventdata, handles)
    else
        pushbutton_Zmoveleft_Callback(hObject, eventdata, handles)
    end
elseif strcmpi(keyPressed,'s')
    if get(handles.radiobutton_XYview,'Value')
        pushbutton_Ymoveright_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_XZview,'Value')
        pushbutton_Zmoveright_Callback(hObject, eventdata, handles)
    else
        pushbutton_Zmoveright_Callback(hObject, eventdata, handles)
    end
elseif strcmpi(keyPressed,'escape')
    if isfield(Data.Graph,'addSegment')
        Data.Graph = rmfield(Data.Graph,'addSegment');
    end
    if isfield(Data.Graph,'addSegmentSnode')
        Data.Graph = rmfield(Data.Graph,'addSegmentSnode');
    end
     if isfield(Data.Graph,'addSegmentEnode')
        Data.Graph = rmfield(Data.Graph,'addSegmentEnode');
     end
    draw(hObject, eventdata, handles)
elseif strcmpi(keyPressed,'return')
    if isfield(Data,'Graph') && isfield(Data.Graph,'addSegment')
        addSegment(hObject, eventdata, handles)
        draw(hObject, eventdata, handles)
    else
        return
    end
end


% --- Executes on button press in pushbutton_updateVolume.
function pushbutton_updateVolume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_updateVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

hWait = waitbar( 0, 'Imaging graph...' );
if get(handles.checkbox_prcoessVisible,'Value')
    if isfield(Data.Graph,'verifiedNodes') && isfield(Data.Graph,'verifiedEdges') 
        nodes = Data.Graph.nodes;
        edges = Data.Graph.edges;
        [Sz,Sx,Sy] = size(Data.angio);
        Zstartframe = str2double(get(handles.edit_Zstartframe,'String'));
        Zstartframe = min(max(Zstartframe,1),Sz);
        ZMIP = str2double(get(handles.edit_ZMIP,'String'));
        Zendframe = min(max(Zstartframe+ZMIP-1,1),Sz);
        Xstartframe = str2double(get(handles.edit_XcenterZoom,'String'));
        Xstartframe = min(max(Xstartframe,1),Sx);
        XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
        Xendframe = min(max(Xstartframe+XMIP-1,1),Sx);
        Ystartframe = str2double(get(handles.edit_YcenterZoom,'String'));
        Ystartframe = min(max(Ystartframe,1),Sy);
        YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
        Yendframe = min(max(Ystartframe+YMIP-1,1),Sy);
        
         idx = find(Data.Graph.nodes(:,3)>= Zstartframe & Data.Graph.nodes(:,3) <= Zendframe ...
        & Data.Graph.nodes(:,1)>= Data.ZoomXrange(1) & Data.Graph.nodes(:,1) <= Data.ZoomXrange(2) ...
        & Data.Graph.nodes(:,2)>= Data.ZoomYrange(1) & Data.Graph.nodes(:,2) <= Data.ZoomYrange(2));
        length(idx)
        edgesIdx = unique(find(ismember(edges(:,1),idx) | ismember(edges(:,2),idx)));
        n_edges = length(edgesIdx)
        for ii = 1:n_edges
                waitbar(ii/n_edges,hWait);  %updating waitbar takes a long time
            pos0 = max(nodes(edges( edgesIdx(ii),1),:),1);
            pos1 = max(nodes(edges( edgesIdx(ii),2),:),1);
            rsep = norm(pos1-pos0);
            if rsep>0
                cxyz = (pos1-pos0) / rsep;
                rstep = 0;
                pos = pos0;
                while rstep<rsep
                    %             im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
                    Data.angioVolume(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 252+1*Data.Graph.verifiedEdges(ii);
                    pos = pos + cxyz*0.5;
                    %if pos(1)<2 & pos(2)<2
                    %    keyboard
                    %end
                    rstep = rstep + 0.5;
                end
            end
            idx = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
            Data.angioVolume(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx(1));
            idx = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
            Data.angioVolume(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx(1));
            %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
            %     angio(Z,Y,X) = 254;
        end
        
        
    end
else
    
    nodes = Data.Graph.nodes;
    edges = Data.Graph.edges;
    angio = Data.angio;
    minI = str2double(get(handles.edit_minI,'String'));
    maxI = str2double(get(handles.edit_maxI,'String'));
    angio(angio < minI) = minI;
    angio(angio > maxI) = maxI;
    angio = 250*(angio-min(angio(:)))/(max(angio(:))-min(angio(:)));
    [Sz,Sx,Sy] = size(Data.angio);
    nEdges = size(edges,1);
    if ~isfield(Data.Graph,'verifiedNodes')
        Data.Graph.verifiedNodes = zeros(size(Data.Graph.nodes,1),1);
    end
    if ~isfield(Data.Graph,'verifiedEdges')
        Data.Graph.verifiedEdges = zeros(size(Data.Graph.edges,1),1);
    end
    for ii = 1:nEdges
        if isequal(rem(ii,1000), 0)
        waitbar(ii/nEdges,hWait);  %updating waitbar takes a long time
        end
        pos0 = max(nodes(edges(ii,1),:),1);
        pos1 = max(nodes(edges(ii,2),:),1);
        rsep = norm(pos1-pos0);
         if rsep>0
            cxyz = (pos1-pos0) / rsep;
            rstep = 0;
            pos = pos0;
            while rstep<rsep
    %             im.III(round(pos(2)),round(pos(1)),max(round(pos(3)),1)) = min(250 - edgeFlag(ii) + grp(nodeEdges(ii,1)),254);
                angio(max(round(pos(3)),1),round(pos(2)),round(pos(1))) = 252+1*Data.Graph.verifiedEdges(ii);           
                pos = pos + cxyz*0.5;
                %if pos(1)<2 & pos(2)<2
                %    keyboard
                %end
                rstep = rstep + 0.5;
            end
         end
        idx = find(Data.Graph.nodes(:,1) == pos0(1) & Data.Graph.nodes(:,2) == pos0(2) & Data.Graph.nodes(:,3) == pos0(3));
        angio(round(pos0(3)),round(pos0(2)),round(pos0(1))) = 254+1*Data.Graph.verifiedNodes(idx(1));
       idx = find(Data.Graph.nodes(:,1) == pos1(1) & Data.Graph.nodes(:,2) == pos1(2) & Data.Graph.nodes(:,3) == pos1(3));
        angio(round(pos1(3)),round(pos1(2)),round(pos1(1))) = 254+1*Data.Graph.verifiedNodes(idx(1));
    %     [X,Y,Z] = bresenham_line3d(nodes(edges(u,1),:),nodes(edges(u,2),:));
    %     angio(Z,Y,X) = 254;
    end

    % nodes = [min(max(round(nodes(:,3)),1),Sz) min(max(round(nodes(:,1)),1),Sx) min(max(round(nodes(:,2)),1),Sy)];
    % angio(nodes) = 257;
    % 
    % for u = 1:size(nodes,1)
    %     u
    %     Z = min(max(round(nodes(u,3)),1),Sz);
    %     X = min(max(round(nodes(u,1)),1),Sx);
    %     Y = min(max(round(nodes(u,2)),1),Sy);
    %     angio(Z,Y,X) = 255;
    % end
    Data.angioVolume = angio;
end
close(hWait);
draw(hObject, eventdata, handles)



function [X,Y,Z] = bresenham_line3d(P1, P2, precision)

   if ~exist('precision','var') | isempty(precision) | round(precision) == 0
      precision = 0;
      P1 = round(P1);
      P2 = round(P2);
   else
      precision = round(precision);
      P1 = round(P1*(10^precision));
      P2 = round(P2*(10^precision));
   end

   d = max(abs(P2-P1)+1);
   X = zeros(1, d);
   Y = zeros(1, d);
   Z = zeros(1, d);

   x1 = P1(1);
   y1 = P1(2);
   z1 = P1(3);

   x2 = P2(1);
   y2 = P2(2);
   z2 = P2(3);

   dx = x2 - x1;
   dy = y2 - y1;
   dz = z2 - z1;

   ax = abs(dx)*2;
   ay = abs(dy)*2;
   az = abs(dz)*2;

   sx = sign(dx);
   sy = sign(dy);
   sz = sign(dz);

   x = x1;
   y = y1;
   z = z1;
   idx = 1;

   if(ax>=max(ay,az))			% x dominant
      yd = ay - ax/2;
      zd = az - ax/2;

      while(1)
         X(idx) = x;
         Y(idx) = y;
         Z(idx) = z;
         idx = idx + 1;

         if(x == x2)		% end
            break;
         end

         if(yd >= 0)		% move along y
            y = y + sy;
            yd = yd - ax;
         end

         if(zd >= 0)		% move along z
            z = z + sz;
            zd = zd - ax;
         end

         x  = x  + sx;		% move along x
         yd = yd + ay;
         zd = zd + az;
      end
   elseif(ay>=max(ax,az))		% y dominant
      xd = ax - ay/2;
      zd = az - ay/2;

      while(1)
         X(idx) = x;
         Y(idx) = y;
         Z(idx) = z;
         idx = idx + 1;

         if(y == y2)		% end
            break;
         end

         if(xd >= 0)		% move along x
            x = x + sx;
            xd = xd - ay;
         end

         if(zd >= 0)		% move along z
            z = z + sz;
            zd = zd - ay;
         end

         y  = y  + sy;		% move along y
         xd = xd + ax;
         zd = zd + az;
      end
   elseif(az>=max(ax,ay))		% z dominant
      xd = ax - az/2;
      yd = ay - az/2;

      while(1)
         X(idx) = x;
         Y(idx) = y;
         Z(idx) = z;
         idx = idx + 1;

         if(z == z2)		% end
            break;
         end

         if(xd >= 0)		% move along x
            x = x + sx;
            xd = xd - az;
         end

         if(yd >= 0)		% move along y
            y = y + sy;
            yd = yd - az;
         end

         z  = z  + sz;		% move along z
         xd = xd + ax;
         yd = yd + ay;
      end
   end

   if precision ~= 0
      X = X/(10^precision);
      Y = Y/(10^precision);
      Z = Z/(10^precision);
   end

   return;					% bresenham_line3d




% --- Executes on button press in radiobutton_fastDisplay.
function radiobutton_fastDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_fastDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_fastDisplay

draw(hObject, eventdata, handles);


% % --- Executes on button press in checkbox_addEdge.
% function checkbox_addEdge_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox_addEdge (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of checkbox_addEdge
% 
% 
% % --- Executes on button press in checkbox_pruneEdge.
% function checkbox_pruneEdge_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox_pruneEdge (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of checkbox_pruneEdge


% --------------------------------------------------------------------
% function meshing_validateSegments_Callback(hObject, eventdata, handles)
% % hObject    handle to meshing_validateSegments (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% global Data
% 
% if isfield(Data.Graph,'segInfo')
%     nodeSegN = Data.Graph.segInfo.nodeSegN;
%     Seg_count = max(nodeSegN(:));
%     ZMIP = str2double(get(handles.edit_ZMIP,'String'));
%     XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
%     YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
%     for u = 3000:Seg_count
%         seg_nodes = find(nodeSegN == u);
% %         mean_x = round(max(min(Data.Graph.nodes(seg_nodes,1)),1))
% %         mean_y = round(max(min(Data.Graph.nodes(seg_nodes,2)),1))
% %         mean_z = round(max(min(Data.Graph.nodes(seg_nodes,3)),1))
%         mean_x = round(max(mean(Data.Graph.nodes(seg_nodes,1)),1))
%         mean_y = round(max(mean(Data.Graph.nodes(seg_nodes,2)),1))
%         mean_z = round(max(mean(Data.Graph.nodes(seg_nodes,3)),1))
%         set(handles.edit_XcenterZoom,'String',num2str(max(mean_x-round(XMIP/2),1)));
%         set(handles.edit_YcenterZoom,'String',num2str(max(mean_y-round(YMIP/2),1)));
%         set(handles.edit_Zstartframe,'String',num2str(max(mean_z-round(ZMIP/2),1)));
%         Data.Graph.verifiedNodes(seg_nodes) = 3;
%         draw(hObject, eventdata, handles);
% %         draw now
%         choice = questdlg('Do you want to validate this segment?', ...
%                 'Segment Validation', ...
%                 'Validate','Do not validate','Quit','Quit');
%         if strcmp(choice,'Validate')
%             Data.Graph.verifiedNodes(seg_nodes) = 1;
%         elseif strcmp(choice,'Do not validate')
%             Data.Graph.verifiedNodes(seg_nodes) = 0;
%         elseif strcmp(choice,'Quit')
%             Data.Graph.verifiedNodes(seg_nodes) = 0;
%             break;
%         end
%     end
% end


% --------------------------------------------------------------------
function verification_getSegInfo_Callback(hObject, eventdata, handles)
% hObject    handle to verification_getSegInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pushbutton_prevSegment.
function pushbutton_prevSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prevSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
if get(handles.checkbox_verifyNotes,'Value')
    if isfield(Data,'currentNote')
        currentNote = max(Data.currentNote-1,1);
    else
        currentNote = 1;
    end
     Data.currentNote = currentNote;
     checkbox_verifyNotes_Callback(hObject, eventdata, handles)
elseif isfield(Data.Graph,'segInfo')
 nodeSegN = Data.Graph.segInfo.nodeSegN;
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    checkmark = get(handles.Unverified_endSegments,'checked');
        if isfield(Data.Graph,'segno')
        u = Data.Graph.segno;
    else
        u = 1;
        end
     if strcmp(get(handles.AllSegments_nBG3,'checked'),'on')
        if ~isfield(Data.Graph,'nodeno')
            Data.Graph.nodeno = 1;
        end
        nBG3_idx = find(Data.Graph.nB>3);
        nBG3 = Data.Graph.endNodes(nBG3_idx);
        Data.Graph.nodeno = max(Data.Graph.nodeno-1,1);
        nodeno = nBG3(Data.Graph.nodeno);
        segs = unique(find(Data.Graph.segInfo.segEndNodes(:,1) == nodeno | Data.Graph.segInfo.segEndNodes(:,2) == nodeno));
        segslength = Data.Graph.segInfo.segLen(segs);
        [~,idx] = min(segslength);
        %         [~,idx] = min(abs(nBG3 -Data.Graph.segno));
        Data.Graph.segno = segs(idx(1));
        u = Data.Graph.segno;
      elseif strcmp(get(handles.AllSegments_loops,'checked'),'on')
        if ~isfield(Data.Graph.segInfo,'loopno')
            Data.Graph.segInfo.loopno = 1;
        else
             Data.Graph.segInfo.loopno = max(Data.Graph.segInfo.loopno-1,1);
        end
        nodeno = Data.Graph.segInfo.loops(Data.Graph.segInfo.loopno);
        Data.Graph.segno = Data.Graph.segInfo.nodeSegN(nodeno);
        u = Data.Graph.segno;
    else
    if  strcmp(get(handles.Groups_All,'checked'),'off')
        if strcmp(get(handles.verification_allSegments,'checked'),'on')
%             [~,u] = min(abs(Data.Graph.segInfo.segmentsGrpOrder-u));
             L = length(Data.Graph.segInfo.segmentsGrpOrder);   
            if strcmp(get(handles.Group_groupWithMostSegments,'checked'),'on')
%                 u = Data.Graph.segnoMS;
%                 u = min(u-1,length(Data.Graph.segInfo.segmentsGrpOrder));
                Data.Graph.segnoMS = max(Data.Graph.segnoMS-1,1);
                u = Data.Graph.segInfo.segmentsGrpOrder(Data.Graph.segnoMS);
          
            elseif strcmp(get(handles.Groups_groupswithleastsegments,'checked'),'on')
                Data.Graph.segnoLS = max(Data.Graph.segnoLS-1,1);
                u = Data.Graph.segnoLS; 
                u = max(L-u,1);
                u = Data.Graph.segInfo.segmentsGrpOrder(u);
            end
        elseif strcmp(get(handles.unverified,'checked'),'on')
             [~,u] = min(abs(Data.Graph.segInfo.segmentsGrpOrder-u));
            if strcmp(get(handles.Group_groupWithMostSegments,'checked'),'on')
%                 u = Data.Graph.segnoMS;
%                 u = min(u-1,length(Data.Graph.segInfo.segmentsGrpOrder));
                Data.Graph.segnoMS = max(Data.Graph.segnoMS-1,1);
                u = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(Data.Graph.segnoMS);
            elseif strcmp(get(handles.Groups_groupswithleastsegments,'checked'),'on')
                Data.Graph.segnoLS = max(Data.Graph.segnoLS-1,1);
                u = Data.Graph.segnoLS;
                L = length(Data.Graph.segInfo.segmentsUnverifiedGrpOrder);
                u = max(L-u,1);
                u = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(u);
            end
        end
    else
        if strcmp(get(handles.verification_allSegments,'checked'),'on')
            if strcmp(get(handles.AllSegments_All,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                    u = max(u-1,1);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{1}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_idx_end{1}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_idx_end{1}(u);
                end
            elseif strcmp(get(handles.AllSegments_lessthan3nodes,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.A_Idx3-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_Idx3));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_Idx3(u);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{2}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_idx_end{2}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_idx_end{2}(u);
                end
            elseif strcmp(get(handles.AllSegments_lessthan5nodes,'checked'),'on')
                 if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.A_Idx5-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_Idx5));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_Idx5(u);
                 else
                    [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{3}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_idx_end{3}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_idx_end{3}(u);
                 end
            elseif strcmp(get(handles.AllSegments_lessthan10nodes,'checked'),'on')
                if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.A_Idx10-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_Idx10));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_Idx10(u);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{4}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.A_idx_end{4}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.A_idx_end{4}(u);
                end
            end
        elseif strcmp(get(handles.unverified,'checked'),'on')
            if strcmp(get(handles.unverifedAllNodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx-u));
%                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.unverifiedIdx(u);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.idx_end{1}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.idx_end{1}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.idx_end{1}(u);
                end
            elseif strcmp(get(handles.unverifedlessthan3Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx3-u));
%                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx3));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.unverifiedIdx3(u);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.idx_end{2}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.idx_end{2}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.idx_end{2}(u);
                end
            elseif strcmp(get(handles.unverifedlessthan5Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx5-u));
%                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx5));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.unverifiedIdx5(u);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.idx_end{3}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.idx_end{3}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.idx_end{3}(u);
                end
            elseif strcmp(get(handles.unverifedlessthan10Nodes,'checked'),'on')
                if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                    [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx10-u));
%                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx10));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.unverifiedIdx10(u);
                else
                    [~,u] = min(abs(Data.Graph.segInfo.idx_end{4}-u));
%                     u = min(u+1,length(Data.Graph.segInfo.idx_end{4}));
                    u = max(u-1,1);
                    u = Data.Graph.segInfo.idx_end{4}(u);
                end
            end
        end
    end
     end
%     if isfield(Data.Graph.segInfo, 'V')
%         if Data.Graph.segInfo.V == 0
%             if isfield(Data.Graph,'segnoVAll')
%                 u = Data.Graph.segnoVAll;
%                 u = max(u-1,1);
%             else
%                 u = 1;
%             end 
%             Data.Graph.segnoVAll = u;
%         elseif Data.Graph.segInfo.V == 1
%             if isfield(Data.Graph,'segnoAll')
%                 if strcmp(checkmark,'off')
%                     [~,u] = min(abs((Data.Graph.segInfo.unverifiedIdx-Data.Graph.segnoAll)));
%                     u = max(u-1,1);
%                     u = Data.Graph.segInfo.unverifiedIdx(u);
%                 else 
%                     [~,u] = min(abs((Data.Graph.segInfo.idx_end{1}-Data.Graph.segnoAll)));
%                     u = max(u-1,1);
%                     u = Data.Graph.segInfo.idx_end{1}(u);
%                 end
%                 
%             else
%                 if strcmp(checkmark,'off')
%                     u = Data.Graph.segInfo.unverifiedIdx(1);
%                 else
%                     u = Data.Graph.segInfo.idx_end{1}(1);
%                 end
%             end
%             Data.Graph.segnoAll = u;
%         elseif Data.Graph.segInfo.V == 3
%             if isfield(Data.Graph,'segno3')
%                 if strcmp(checkmark,'off')
%                     [~,u] = min(abs((Data.Graph.segInfo.unverifiedIdx3-Data.Graph.segno3)));
%                     u = max(u-1,1);
%                     u = Data.Graph.segInfo.unverifiedIdx3(u);
%                 else
%                     [~,u] = min(abs((Data.Graph.segInfo.idx_end{2}-Data.Graph.segno3)));
%                     u = max(u-1,1);
%                     u = Data.Graph.segInfo.idx_end{2}(u);
%                 end
%             else
%                 if strcmp(checkmark,'off')
%                     u = Data.Graph.segInfo.unverifiedIdx3(1);
%                 else
%                     u = Data.Graph.segInfo.idx_end{2}(1);
%                 end
%             end 
%             Data.Graph.segno3 = u;
%         elseif Data.Graph.segInfo.V == 5
%             if isfield(Data.Graph,'segno5')
%                  if strcmp(checkmark,'off')
%                     [~,u] = min(abs((Data.Graph.segInfo.unverifiedIdx5-Data.Graph.segno5)));
%                     u = max(u-1,1);
%                     u = Data.Graph.segInfo.unverifiedIdx5(u);
%                  else
%                     [~,u] = min(abs((Data.Graph.segInfo.idx_end{3}-Data.Graph.segno5)));
%                     u = max(u-1,1);
%                     u = Data.Graph.segInfo.idx_end{3}(u);
%                  end
%             else
%                 if strcmp(checkmark,'off')
%                     u = Data.Graph.segInfo.unverifiedIdx5(1);
%                 else
%                     u = Data.Graph.segInfo.idx_end{3}(1);
%                 end
%             end 
%             Data.Graph.segno5 = u;
%         elseif Data.Graph.segInfo.V == 10
%             if isfield(Data.Graph,'segno10')
%                  if strcmp(checkmark,'off')
%                      [~,u] = min(abs((Data.Graph.segInfo.unverifiedIdx10-Data.Graph.segno10)));
%                      u = max(u-1,1);
%                      u = Data.Graph.segInfo.unverifiedIdx10(u);
%                  else
%                      [~,u] = min(abs((Data.Graph.segInfo.idx_end{4}-Data.Graph.segno10)));
%                      u = max(u-1,1);
%                      u = Data.Graph.segInfo.idx_end{4}(u);
%                  end
%             else
%                 if strcmp(checkmark,'off')
%                     u = Data.Graph.segInfo.unverifiedIdx10(1);
%                 else
%                     u = Data.Graph.segInfo.idx_end{4}(1);
%                 end
%             end
%              Data.Graph.segno10 = u;
%         end
%             
%     else
%         if isfield(Data.Graph,'segnoVAll')
%             u = Data.Graph.segnoVAll;
%             u = min(u-1,1);
%             Data.Graph.segnoVAll = u;
%         else
%             u = 1;
%           Data.Graph.segnoVAll = u;
%         end
%     end
    Data.Graph.segno = u;
    endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
    seg_nodes = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);
    
     u1 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,1);
    u2 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,2);
    idx1 = find((Data.Graph.segInfo.segEndNodes(:,1) == u1) | (Data.Graph.segInfo.segEndNodes(:,2) == u1));
    idx2 = find((Data.Graph.segInfo.segEndNodes(:,1) == u2) | (Data.Graph.segInfo.segEndNodes(:,2) == u2));  
%     idx = setdiff([idx1;idx2],Data.Graph.segno); 
    all_nodes = [];
    for u = 1:length(idx1)
        all_nodes = [all_nodes; find(Data.Graph.segInfo.nodeSegN == idx1(u))];        
    end
    for u = 1:length(idx2)
        all_nodes = [all_nodes; find(Data.Graph.segInfo.nodeSegN == idx2(u))];  
    end
        % Current segment dimensions
    Zmin = min(Data.Graph.nodes(seg_nodes,3));
    Zmax = max(Data.Graph.nodes(seg_nodes,3));
    Xmin = min(Data.Graph.nodes(seg_nodes,1));
    Xmax = max(Data.Graph.nodes(seg_nodes,1));
    Ymin = min(Data.Graph.nodes(seg_nodes,2));
    Ymax = max(Data.Graph.nodes(seg_nodes,2));
    
    % Connected segment dimensions
%     Zmin = min(Data.Graph.nodes(all_nodes,3));
%     Zmax = max(Data.Graph.nodes(all_nodes,3));
%     Xmin = min(Data.Graph.nodes(all_nodes,1));
%     Xmax = max(Data.Graph.nodes(all_nodes,1));
%     Ymin = min(Data.Graph.nodes(all_nodes,2));
%     Ymax = max(Data.Graph.nodes(all_nodes,2));
    
    set(handles.edit_XcenterZoom,'String',num2str(max(round(Xmin+(Xmax-Xmin)/2),1)));
    set(handles.edit_YcenterZoom,'String',num2str(max(round(Ymin+(Ymax-Ymin)/2),1)));
    set(handles.edit_Zstartframe,'String',num2str(max(round(Zmin-10),1)));
    
    set(handles.edit_XwidthZoom,'String',num2str(max(round(Xmax-Xmin+20),1)));
    set(handles.edit_YwidthZoom,'String',num2str(max(round(Ymax-Ymin+20),1)));
    set(handles.edit_ZMIP,'String',num2str(max(round(Zmax-Zmin+20),1)));
        
%     mean_x = round(max(mean(Data.Graph.nodes(seg_nodes,1)),1));
%     mean_y = round(max(mean(Data.Graph.nodes(seg_nodes,2)),1));
%     mean_z = round(max(mean(Data.Graph.nodes(seg_nodes,3)),1));
%     set(handles.edit_XcenterZoom,'String',num2str(max(mean_x-round(XMIP/2),1)));
%     set(handles.edit_YcenterZoom,'String',num2str(max(mean_y-round(YMIP/2),1)));
%     set(handles.edit_Zstartframe,'String',num2str(max(mean_z-round(ZMIP/2),1)));
%     Data.Graph.verifiedNodes(seg_nodes) = 3;
    draw(hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton_nextSegment.
function pushbutton_nextSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nextSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
if get(handles.checkbox_verifyNotes,'Value')
    if isfield(Data,'currentNote')
        currentNote = min(Data.currentNote+1,size(Data.notes,1));
    else
        currentNote = 1;
    end
    Data.currentNote = currentNote;
    checkbox_verifyNotes_Callback(hObject, eventdata, handles)
elseif isfield(Data.Graph,'segInfo')
    nodeSegN = Data.Graph.segInfo.nodeSegN;
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    checkmark = get(handles.Unverified_endSegments,'checked');
    
    if isfield(Data.Graph,'segno')
        u = Data.Graph.segno;
    else
        u = 1;
    end
    if strcmp(get(handles.AllSegments_nBG3,'checked'),'on')
        if ~isfield(Data.Graph,'nodeno')
            Data.Graph.nodeno = 1;
        end
        nBG3_idx = find(Data.Graph.nB>3);
        nBG3 = Data.Graph.endNodes(nBG3_idx);
        Data.Graph.nodeno = min(Data.Graph.nodeno+1,length(nBG3));
        nodeno = nBG3(Data.Graph.nodeno);
        segs = unique(find(Data.Graph.segInfo.segEndNodes(:,1) == nodeno | Data.Graph.segInfo.segEndNodes(:,2) == nodeno));
        segslength = Data.Graph.segInfo.segLen(segs);
        [~,idx] = min(segslength);
        %         [~,idx] = min(abs(nBG3 -Data.Graph.segno));
        Data.Graph.segno = segs(idx(1));
        u = Data.Graph.segno;
    elseif strcmp(get(handles.AllSegments_loops,'checked'),'on')
        if ~isfield(Data.Graph.segInfo,'loopno')
            Data.Graph.segInfo.loopno = 1;
        else
             Data.Graph.segInfo.loopno = min(Data.Graph.segInfo.loopno+1,length(Data.Graph.segInfo.loops));
        end
        nodeno = Data.Graph.segInfo.loops(Data.Graph.segInfo.loopno);
        Data.Graph.segno = Data.Graph.segInfo.nodeSegN(nodeno);
        u = Data.Graph.segno;
    else
        if  strcmp(get(handles.Groups_All,'checked'),'off')
            if strcmp(get(handles.verification_allSegments,'checked'),'on')
                %             [~,u] = min(abs(Data.Graph.segInfo.segmentsGrpOrder-u));
                L = length(Data.Graph.segInfo.segmentsGrpOrder);
                if strcmp(get(handles.Group_groupWithMostSegments,'checked'),'on')
                    %                 u = Data.Graph.segnoMS;
                    %                 u = min(u+1,length(Data.Graph.segInfo.segmentsGrpOrder));
                    Data.Graph.segnoMS = min(Data.Graph.segnoMS+1,length(Data.Graph.segInfo.segmentsGrpOrder));
                    u = Data.Graph.segInfo.segmentsGrpOrder(Data.Graph.segnoMS);
                elseif strcmp(get(handles.Groups_groupswithleastsegments,'checked'),'on')
                    Data.Graph.segnoLS = min(Data.Graph.segnoLS+1,L);
                    u = Data.Graph.segnoLS;
                    u = max(L-u,1);
                    u = Data.Graph.segInfo.segmentsGrpOrder(u);
                    %                 Data.Graph.segnoLS = min(Data.Graph.segnoLS+1,L);
                end
            elseif strcmp(get(handles.unverified,'checked'),'on')
                [~,u] = min(abs(Data.Graph.segInfo.segmentsGrpOrder-u));
                L = length(Data.Graph.segInfo.segmentsUnverifiedGrpOrder);
                if strcmp(get(handles.Group_groupWithMostSegments,'checked'),'on')
                    %                 u = Data.Graph.segnoMS;
                    %                 u = min(u+1,length(Data.Graph.segInfo.segmentsGrpOrder));
                    Data.Graph.segnoMS = min(Data.Graph.segnoMS+1,length(Data.Graph.segInfo.segmentsUnverifiedGrpOrder));
                    u = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(Data.Graph.segnoMS);
                elseif strcmp(get(handles.Groups_groupswithleastsegments,'checked'),'on')
                    Data.Graph.segnoLS = min(Data.Graph.segnoLS+1,L);
                    u = Data.Graph.segnoLS;
                    u = max(L-u,1);
                    u = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(u);
                end
            end
        else
            if strcmp(get(handles.verification_allSegments,'checked'),'on')
                if strcmp(get(handles.AllSegments_All,'checked'),'on')
                    if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                        u = min(u+1,length(Data.Graph.segInfo.segLen));
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{1}-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_idx_end{1}));
                        u = Data.Graph.segInfo.A_idx_end{1}(u);
                    end
                elseif strcmp(get(handles.AllSegments_lessthan3nodes,'checked'),'on')
                    if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.A_Idx3-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_Idx3));
                        u = Data.Graph.segInfo.A_Idx3(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{2}-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_idx_end{2}));
                        u = Data.Graph.segInfo.A_idx_end{2}(u);
                    end
                elseif strcmp(get(handles.AllSegments_lessthan5nodes,'checked'),'on')
                    if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.A_Idx5-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_Idx5));
                        u = Data.Graph.segInfo.A_Idx5(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{3}-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_idx_end{3}));
                        u = Data.Graph.segInfo.A_idx_end{3}(u);
                    end
                elseif strcmp(get(handles.AllSegments_lessthan10nodes,'checked'),'on')
                    if strcmp(get(handles.AllSegments_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.A_Idx10-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_Idx10));
                        u = Data.Graph.segInfo.A_Idx10(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.A_idx_end{4}-u));
                        u = min(u+1,length(Data.Graph.segInfo.A_idx_end{4}));
                        u = Data.Graph.segInfo.A_idx_end{4}(u);
                    end
                end
            elseif strcmp(get(handles.unverified,'checked'),'on')
                if strcmp(get(handles.unverifedAllNodes,'checked'),'on')
                    if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx-u));
                        u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx));
                        u = Data.Graph.segInfo.unverifiedIdx(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.idx_end{1}-u));
                        u = min(u+1,length(Data.Graph.segInfo.idx_end{1}));
                        u = Data.Graph.segInfo.idx_end{1}(u);
                    end
                elseif strcmp(get(handles.unverifedlessthan3Nodes,'checked'),'on')
                    if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx3-u));
                        u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx3));
                        u = Data.Graph.segInfo.unverifiedIdx3(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.idx_end{2}-u));
                        u = min(u+1,length(Data.Graph.segInfo.idx_end{2}));
                        u = Data.Graph.segInfo.idx_end{2}(u);
                    end
                elseif strcmp(get(handles.unverifedlessthan5Nodes,'checked'),'on')
                    if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx5-u));
                        u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx5));
                        u = Data.Graph.segInfo.unverifiedIdx5(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.idx_end{3}-u));
                        u = min(u+1,length(Data.Graph.segInfo.idx_end{3}));
                        u = Data.Graph.segInfo.idx_end{3}(u);
                    end
                elseif strcmp(get(handles.unverifedlessthan10Nodes,'checked'),'on')
                    if strcmp(get(handles.Unverified_endSegments,'checked'),'off')
                        [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx10-u));
                        u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx10));
                        u = Data.Graph.segInfo.unverifiedIdx10(u);
                    else
                        [~,u] = min(abs(Data.Graph.segInfo.idx_end{4}-u));
                        u = min(u+1,length(Data.Graph.segInfo.idx_end{4}));
                        u = Data.Graph.segInfo.idx_end{4}(u);
                    end
                end
            end
        end
    end
    %     if isfield(Data.Graph.segInfo, 'V')
    %         if Data.Graph.segInfo.V == 0
    %             if isfield(Data.Graph,'segnoVAll')
    %                 u = Data.Graph.segnoVAll;
    %                 u = min(u+1,length(Data.Graph.segInfo.segLen));
    %             else
    %                 u = 1;
    %             end
    %             Data.Graph.segnoVAll = u;
    %         elseif Data.Graph.segInfo.V == 1
    %             if isfield(Data.Graph,'segnoAll')
    %                 if strcmp(checkmark,'off')
    %                     [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx-Data.Graph.segnoAll));
    %
    %                 else
    %                     [~,u] = min(abs(Data.Graph.segInfo.idx_end{1}-Data.Graph.segnoAll));
    %                     u = min(u+1,length(Data.Graph.segInfo.idx_end{1}));
    %                     u = Data.Graph.segInfo.idx_end{1}(u);
    %                 end
    %             else
    %                 u = Data.Graph.segInfo.unverifiedIdx(1);
    %             end
    %             Data.Graph.segnoAll = u;
    %         elseif Data.Graph.segInfo.V == 3
    %             if isfield(Data.Graph,'segno3')
    %                 if strcmp(checkmark,'off')
    %                     [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx3-Data.Graph.segno3));
    %                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx3));
    %                     u = Data.Graph.segInfo.unverifiedIdx3(u);
    %                 else
    %                     [~,u] = min(abs(Data.Graph.segInfo.idx_end{2}-Data.Graph.segno3));
    %                     u = min(u+1,length(Data.Graph.segInfo.idx_end{2}));
    %                     u = Data.Graph.segInfo.idx_end{2}(u);
    %                 end
    %             else
    %                 u = Data.Graph.segInfo.unverifiedIdx3(1);
    %             end
    %             Data.Graph.segno3 = u;
    %         elseif Data.Graph.segInfo.V == 5
    %             if isfield(Data.Graph,'segno5')
    %                 if strcmp(checkmark,'off')
    %                     [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx5-Data.Graph.segno5));
    %                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx5));
    %                     u = Data.Graph.segInfo.unverifiedIdx5(u);
    %                 else
    %                     [~,u] = min(abs(Data.Graph.segInfo.idx_end{3}-Data.Graph.segno5));
    %                     u = min(u+1,length(Data.Graph.segInfo.idx_end{3}));
    %                     u = Data.Graph.segInfo.idx_end{3}(u);
    %                 end
    %             else
    %                 u = Data.Graph.segInfo.unverifiedIdx5(1);
    %             end
    %             Data.Graph.segno5 = u;
    %         elseif Data.Graph.segInfo.V == 10
    %             if isfield(Data.Graph,'segno10')
    %                 if strcmp(checkmark,'off')
    %                     [~,u] = min(abs(Data.Graph.segInfo.unverifiedIdx10-Data.Graph.segno10));
    %                     u = min(u+1,length(Data.Graph.segInfo.unverifiedIdx10));
    %                     u = Data.Graph.segInfo.unverifiedIdx10(u);
    %                 else
    %                     [~,u] = min(abs(Data.Graph.segInfo.idx_end{4}-Data.Graph.segno10));
    %                     u = min(u+1,length(Data.Graph.segInfo.idx_end{4}));
    %                     u = Data.Graph.segInfo.idx_end{4}(u);
    %                 end
    %             else
    %                 u = Data.Graph.segInfo.unverifiedIdx10(1);
    %             end
    %             Data.Graph.segno10 = u;
    %         end
    %
    %     else
    %         if isfield(Data.Graph,'segnoVAll')
    %             u = Data.Graph.segnoVAll;
    %             u = min(u+1,length(Data.Graph.segInfo.segLen));
    %             Data.Graph.segnoVAll = u;
    %         else
    %             u = 1;
    %             Data.Graph.segnoVAll = u;
    %         end
    %     end
    Data.Graph.segno = u;
    endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
    seg_nodes = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);
    
    u1 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,1);
    u2 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,2);
    idx1 = find((Data.Graph.segInfo.segEndNodes(:,1) == u1) | (Data.Graph.segInfo.segEndNodes(:,2) == u1));
    idx2 = find((Data.Graph.segInfo.segEndNodes(:,1) == u2) | (Data.Graph.segInfo.segEndNodes(:,2) == u2));
    %     idx = setdiff([idx1;idx2],Data.Graph.segno);
    all_nodes = [];
    for u = 1:length(idx1)
        all_nodes = [all_nodes; find(Data.Graph.segInfo.nodeSegN == idx1(u))];
    end
    for u = 1:length(idx2)
        all_nodes = [all_nodes; find(Data.Graph.segInfo.nodeSegN == idx2(u))];
    end
    
    % Current segment dimensions
    Zmin = min(Data.Graph.nodes(seg_nodes,3));
    Zmax = max(Data.Graph.nodes(seg_nodes,3));
    Xmin = min(Data.Graph.nodes(seg_nodes,1));
    Xmax = max(Data.Graph.nodes(seg_nodes,1));
    Ymin = min(Data.Graph.nodes(seg_nodes,2));
    Ymax = max(Data.Graph.nodes(seg_nodes,2));
    
    % Connected segment dimensions
    %     Zmin = min(Data.Graph.nodes(all_nodes,3));
    %     Zmax = max(Data.Graph.nodes(all_nodes,3));
    %     Xmin = min(Data.Graph.nodes(all_nodes,1));
    %     Xmax = max(Data.Graph.nodes(all_nodes,1));
    %     Ymin = min(Data.Graph.nodes(all_nodes,2));
    %     Ymax = max(Data.Graph.nodes(all_nodes,2));
    
    %
    
    set(handles.edit_XcenterZoom,'String',num2str(max(round(Xmin+(Xmax-Xmin)/2),1)));
    set(handles.edit_YcenterZoom,'String',num2str(max(round(Ymin+(Ymax-Ymin)/2),1)));
    set(handles.edit_Zstartframe,'String',num2str(max(round(Zmin-10),1)));
    
    set(handles.edit_XwidthZoom,'String',num2str(max(round(Xmax-Xmin+20),1)));
    set(handles.edit_YwidthZoom,'String',num2str(max(round(Ymax-Ymin+20),1)));
    set(handles.edit_ZMIP,'String',num2str(max(round(Zmax-Zmin+20),1)));
    
    
    %     mean_x = round(max(mean(Data.Graph.nodes(seg_nodes,1)),1));
    %     mean_y = round(max(mean(Data.Graph.nodes(seg_nodes,2)),1));
    %     mean_z = round(max(mean(Data.Graph.nodes(seg_nodes,3)),1));
    %     set(handles.edit_XcenterZoom,'String',num2str(max(mean_x-round(XMIP/2),1)));
    %     set(handles.edit_YcenterZoom,'String',num2str(max(mean_y-round(YMIP/2),1)));
    %     set(handles.edit_Zstartframe,'String',num2str(max(mean_z-round(ZMIP/2),1)));
    %     Data.Graph.verifiedNodes(seg_nodes) = 3;
    draw(hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton_verifySegment.
function pushbutton_verifySegment_Callback(hObject, eventdata, handles,segNumber)
% hObject    handle to pushbutton_verifySegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
if isfield(Data.Graph,'segInfo')
    if nargin < 4
        if isfield(Data.Graph,'segno')
            u = Data.Graph.segno;
            if ~isfield(Data.Graph,'verifiedSegments')
                Data.Graph.verifiedSegments = zeros(size(nodeSegN));
            end
            Data.Graph.verifiedSegments(u) = 1;
            seg_nodes = find(Data.Graph.segInfo.nodeSegN == u);
            seg_edges = find(Data.Graph.segInfo.edgeSegN == u);
            Data.Graph.verifiedNodes(seg_nodes) = 1;
            Data.Graph.verifiedEdges(seg_edges) = 1;
        end
    else
        u = segNumber;
        if ~isfield(Data.Graph,'verifiedSegments')
            Data.Graph.verifiedSegments = zeros(size(nodeSegN));
        end
        Data.Graph.verifiedSegments(u) = 1;
        seg_nodes = find(Data.Graph.segInfo.nodeSegN == u);
        seg_edges = find(Data.Graph.segInfo.edgeSegN == u);
        Data.Graph.verifiedNodes(seg_nodes) = 1;
        Data.Graph.verifiedEdges(seg_edges) = 1;
    end
end
pushbutton_nextSegment_Callback(hObject, eventdata, handles)
% draw(hObject, eventdata, handles);



% --- Executes on button press in pushbutton49.
function pushbutton49_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
if get(handles.checkbox_verifySegments,'Value') && isfield(Data.Graph,'segInfo')
    if isfield(Data.Graph,'segno')
        u = Data.Graph.segno;
        if ~isfield(Data.Graph,'verifiedSegments')
            Data.Graph.verifiedSegments = zeros(size(nodeSegN));
        end
        Data.Graph.verifiedSegments(u) = 0;
    end
end
draw(hObject, eventdata, handles);

% --- Executes on button press in checkbox_verifySegments.
function checkbox_verifySegments_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_verifySegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_verifySegments

global Data
if get(handles.checkbox_verifySegments,'Value') && isfield(Data.Graph,'segInfo')
    set(handles.checkbox_verifyNotes,'Value',0);
    checkbox_verifyNotes_Callback(hObject, eventdata, handles)
    set(handles.pushbutton_prevSegment,'Enable','on');
    set(handles.pushbutton_nextSegment,'Enable','on');
    set(handles.pushbutton_verifySegment,'Enable','on');
    set(handles.pushbutton49,'Enable','on');
    set(handles.pushbutton_deleteSegment,'Enable','on');
%     nodes = Data.Graph.nodes;
%     edges = Data.Graph.edges;
    nodeSegN = Data.Graph.segInfo.nodeSegN;
    ZMIP = str2double(get(handles.edit_ZMIP,'String'));
    XMIP = str2double(get(handles.edit_XwidthZoom,'String'));
    YMIP = str2double(get(handles.edit_YwidthZoom,'String'));
    if isfield(Data.Graph,'segno')
        u = Data.Graph.segno;
    else
        u = 1;
        Data.Graph.segno = u;
%         Data.Graph.verifiedSegments = zeros(size(segPos,1),1);
    end
    
    Data.Graph.segno = u;
    endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
    seg_nodes = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);
    
    u1 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,1);
    u2 = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,2);
    idx1 = find((Data.Graph.segInfo.segEndNodes(:,1) == u1) | (Data.Graph.segInfo.segEndNodes(:,2) == u1));
    idx2 = find((Data.Graph.segInfo.segEndNodes(:,1) == u2) | (Data.Graph.segInfo.segEndNodes(:,2) == u2));  
%     idx = setdiff([idx1;idx2],Data.Graph.segno); 
    all_nodes = [];
    for u = 1:length(idx1)
        all_nodes = [all_nodes; find(Data.Graph.segInfo.nodeSegN == idx1(u))];        
    end
    for u = 1:length(idx2)
        all_nodes = [all_nodes; find(Data.Graph.segInfo.nodeSegN == idx2(u))];  
    end
        % Current segment dimensions
    Zmin = min(Data.Graph.nodes(seg_nodes,3));
    Zmax = max(Data.Graph.nodes(seg_nodes,3));
    Xmin = min(Data.Graph.nodes(seg_nodes,1));
    Xmax = max(Data.Graph.nodes(seg_nodes,1));
    Ymin = min(Data.Graph.nodes(seg_nodes,2));
    Ymax = max(Data.Graph.nodes(seg_nodes,2));
    
    % Connected segment dimensions
%     Zmin = min(Data.Graph.nodes(all_nodes,3));
%     Zmax = max(Data.Graph.nodes(all_nodes,3));
%     Xmin = min(Data.Graph.nodes(all_nodes,1));
%     Xmax = max(Data.Graph.nodes(all_nodes,1));
%     Ymin = min(Data.Graph.nodes(all_nodes,2));
%     Ymax = max(Data.Graph.nodes(all_nodes,2));
    
    set(handles.edit_XcenterZoom,'String',num2str(max(round(Xmin+(Xmax-Xmin)/2),1)));
    set(handles.edit_YcenterZoom,'String',num2str(max(round(Ymin+(Ymax-Ymin)/2),1)));
    set(handles.edit_Zstartframe,'String',num2str(max(round(Zmin-10),1)));
    
    set(handles.edit_XwidthZoom,'String',num2str(max(round(Xmax-Xmin+20),1)));
    set(handles.edit_YwidthZoom,'String',num2str(max(round(Ymax-Ymin+20),1)));
    set(handles.edit_ZMIP,'String',num2str(max(round(Zmax-Zmin+20),1)));
    
%     mean_x = round(max(mean(Data.Graph.nodes(seg_nodes,1)),1));
%     mean_y = round(max(mean(Data.Graph.nodes(seg_nodes,2)),1));
%     mean_z = round(max(mean(Data.Graph.nodes(seg_nodes,3)),1));
%     set(handles.edit_XcenterZoom,'String',num2str(max(mean_x-round(XMIP/2),1)));
%     set(handles.edit_YcenterZoom,'String',num2str(max(mean_y-round(YMIP/2),1)));
%     set(handles.edit_Zstartframe,'String',num2str(max(mean_z-round(ZMIP/2),1)));
%     Data.Graph.verifiedNodes(seg_nodes) = 3;
%     seg_nodes = find(nodeSegN == u);
%     mean_x = round(max(mean(Data.Graph.nodes(seg_nodes,1)),1));
%     mean_y = round(max(mean(Data.Graph.nodes(seg_nodes,2)),1))
%     mean_z = round(max(mean(Data.Graph.nodes(seg_nodes,3)),1))
%     set(handles.edit_XcenterZoom,'String',num2str(max(mean_x-round(XMIP/2),1)));
%     set(handles.edit_YcenterZoom,'String',num2str(max(mean_y-round(YMIP/2),1)));
%     set(handles.edit_Zstartframe,'String',num2str(max(mean_z-round(ZMIP/2),1)));
%     Data.Graph.verifiedNodes(seg_nodes) = 3;
elseif ~get(handles.checkbox_verifySegments,'Value')
    set(handles.pushbutton_prevSegment,'Enable','off');
    set(handles.pushbutton_nextSegment,'Enable','off');
    set(handles.pushbutton_verifySegment,'Enable','off');
    set(handles.pushbutton49,'Enable','off');
    set(handles.pushbutton_deleteSegment,'Enable','off');
end
draw(hObject, eventdata, handles);



function edit_maxI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maxI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_maxI as text
%        str2double(get(hObject,'String')) returns contents of edit_maxI as a double
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_maxI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maxI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_minI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_minI as text
%        str2double(get(hObject,'String')) returns contents of edit_minI as a double
draw(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_minI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Ithresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Ithresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Ithresh as text
%        str2double(get(hObject,'String')) returns contents of edit_Ithresh as a double


% --- Executes during object creation, after setting all properties.
function edit_Ithresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Ithresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Save_GraphData_Callback(hObject, eventdata, handles)
% hObject    handle to Save_GraphData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

Graph = Data.Graph;
[FileName,PathName] = uiputfile('*.mat','Please save the Graph Data as');
save([PathName FileName],'Graph');


% --------------------------------------------------------------------
function File_loadGraphData_Callback(hObject, eventdata, handles)
% hObject    handle to File_loadGraphData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
[filename,pathname] = uigetfile('*.mat','Please load the Graph Data');
load([pathname filename]);
Data.Graph = Graph;
set(handles.checkboxDisplayGraph,'enable','on')
draw(hObject, eventdata, handles);



% --------------------------------------------------------------------
function verification_Callback(hObject, eventdata, handles)
% hObject    handle to verification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function verification_allSegments_Callback(hObject, eventdata, handles)
% hObject    handle to verification_allSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global Data
% Data.Graph.segInfo.V = 0;
% set(handles.verification_allSegments,'checked','on');
% set(handles.unverified,'checked','off');
% set(handles.unverifedlessthan3Nodes,'checked','off');
% set(handles.unverifedlessthan5Nodes,'checked','off');
% set(handles.unverifedlessthan10Nodes,'checked','off');
% set(handles.unverifedAllNodes,'checked','off');

% --------------------------------------------------------------------
function unverified_Callback(hObject, eventdata, handles)
% hObject    handle to unverified (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function unverifedlessthan3Nodes_Callback(hObject, eventdata, handles)
% hObject    handle to unverifedlessthan3Nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
Data.Graph.segInfo.V = 3;
set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','off');

set(handles.unverified,'checked','on');
set(handles.unverifedlessthan3Nodes,'checked','on');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','off');

% --------------------------------------------------------------------
function unverifedlessthan5Nodes_Callback(hObject, eventdata, handles)
% hObject    handle to unverifedlessthan5Nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
Data.Graph.segInfo.V = 5;
set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','off');

set(handles.unverified,'checked','on');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','on');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','off');


% --------------------------------------------------------------------
function unverifedlessthan10Nodes_Callback(hObject, eventdata, handles)
% hObject    handle to unverifedlessthan10Nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
Data.Graph.segInfo.V = 10;
set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','off');

set(handles.unverified,'checked','on');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','on');
set(handles.unverifedAllNodes,'checked','off');

% --------------------------------------------------------------------
function unverifedAllNodes_Callback(hObject, eventdata, handles)
% hObject    handle to unverifedAllNodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
Data.Graph.segInfo.V = 1;
set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','off');

set(handles.unverified,'checked','on');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','on');

% --------------------------------------------------------------------
function verification_updateBranchInfo_Callback(hObject, eventdata, handles)
% hObject    handle to verification_updateBranchInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

% if isfield(Data.Graph,'verifiedSegments')
    h = waitbar(0,'Please wait... loading the data');
    nSeg = size(Data.Graph.segInfo.segEndNodes,1);
    idx3 = [];            A_idx3 = [];
    idx5 = [];            A_idx5 = [];
    idx10 = [];           A_idx10 = [];
    idx_end = cell(4,1);  A_idx_end = cell(4,1);
    iall = 1; i3 = 1; i5 = 1; i10 = 1;
    A_iall = 1; A_i3 = 1; A_i5 = 1; A_i10 = 1;
    for u = 1:nSeg
        waitbar(u/nSeg);
        temp_idx = find(Data.Graph.segInfo.nodeSegN == u);
        endnodes = Data.Graph.segInfo.segEndNodes(u,:);
        %        nc1 = length(find(Data.Graph.edges(:,1) == endnodes(1) |Data.Graph.edges(:,2) == endnodes(1)));
        %        nc2 = length(find(Data.Graph.edges(:,1) == endnodes(2) |Data.Graph.edges(:,2) == endnodes(2)));
        nc1 = length(find((Data.Graph.segInfo.segEndNodes(:,1) == endnodes(1)) | (Data.Graph.segInfo.segEndNodes(:,2) == endnodes(1))));
        nc2 = length(find((Data.Graph.segInfo.segEndNodes(:,1) == endnodes(2)) | (Data.Graph.segInfo.segEndNodes(:,2) == endnodes(2))));
        if nc1 < 2 || nc2 < 2
            endnode = 1;
        else
            endnode = 0;
        end
        if 1 
%             ~Data.Graph.verifiedSegments(u)
            if endnode == 1
                idx_end{1}(iall) = u;
                iall = iall+1;
            end
            if length(temp_idx) <= 3
                idx3 = [idx3; u];
                if endnode == 1
                    idx_end{2}(i3) = u;
                    i3 = i3+1;
                end
            elseif length(temp_idx) <= 5
                idx5 = [idx5; u];
                if endnode == 1
                    idx_end{3}(i5) = u;
                    i5 = i5+1;
                end
            elseif length(temp_idx) <= 10
                idx10 = [idx10; u];
                if endnode == 1
                    idx_end{4}(i10) = u;
                    i10 = i10+1;
                end
                
            end
        end
        if endnode == 1
            A_idx_end{1}(A_iall) = u;
            A_iall = A_iall+1;
        end
        if length(temp_idx) <= 3
            A_idx3 = [A_idx3; u];
            if endnode == 1
                A_idx_end{2}(A_i3) = u;
                A_i3 = A_i3+1;
            end
        elseif length(temp_idx) <= 5
            A_idx5 = [A_idx5; u];
            if endnode == 1
                A_idx_end{3}(A_i5) = u;
                A_i5 = A_i5+1;
            end
        elseif length(temp_idx) <= 10
            A_idx10 = [A_idx10; u];
            if endnode == 1
                A_idx_end{4}(A_i10) = u;
                A_i10 = A_i10+1;
            end
        end
          
    end
    
    % number of bifurcations at end node
    endnodes1 = unique(Data.Graph.segInfo.segEndNodes(:,1));
    endnodes2 = unique(Data.Graph.segInfo.segEndNodes(:,2));
    unique_endnodes = unique([endnodes1;endnodes2]);
    Data.Graph.endNodes = zeros(size(unique_endnodes));
    nB = zeros(size(unique_endnodes));
    for ii=1:length(unique_endnodes)
        nB(ii) = length(find(Data.Graph.segInfo.segEndNodes(:)==unique_endnodes(ii))); 
        Data.Graph.endNodes(ii) = unique_endnodes(ii);
    end
    Data.Graph.nB = nB;
    if ~isfield(Data.Graph,'verifiedSegments')
        Data.Graph.verifiedSegments = zeros(size(Data.Graph.segInfo.segLen));
    end
    idx = find(Data.Graph.verifiedSegments == 0);
    Data.Graph.segInfo.unverifiedIdx = idx;
    Data.Graph.segInfo.unverifiedIdx3 = idx3;
    Data.Graph.segInfo.unverifiedIdx5 = idx5;
    Data.Graph.segInfo.unverifiedIdx10 = idx10;
    Data.Graph.segInfo.idx_end = idx_end;
    %         Data.Graph.segInfo.A_unverifiedIdx = A_idx;
    Data.Graph.segInfo.A_Idx3 = A_idx3;
    Data.Graph.segInfo.A_Idx5 = A_idx5;
    Data.Graph.segInfo.A_Idx10 = A_idx10;
    Data.Graph.segInfo.A_idx_end = A_idx_end;
    if isfield(Data.Graph.segInfo,'segCGrps')
        grpLengths = zeros(1,length(Data.Graph.segInfo.segCGrps(:)));
        for u = 1:length(Data.Graph.segInfo.segCGrps)
            idx = find(Data.Graph.segInfo.segCGrps == u);
            grpLengths(u) = length(idx);
        end
        [~,id] = sort(grpLengths,'descend');
        segmentsGrpOrder = zeros(length(Data.Graph.segInfo.segCGrps),2);
        segmentsUnverifiedGrpOrder = zeros(length(find(Data.Graph.verifiedSegments == 0)),2);
        sidx = 1;
        usidx = 1;
        for u = 1:length(id)
            idx = find(Data.Graph.segInfo.segCGrps == id(u));
            tempidx = find( Data.Graph.verifiedSegments == 0 );
            uidx = intersect(idx,tempidx);
            segmentsGrpOrder(sidx:sidx+length(idx)-1,1) = idx;
            segmentsGrpOrder(sidx:sidx+length(idx)-1,2) = u;
            segmentsUnverifiedGrpOrder(usidx:usidx+length(uidx)-1,1) = uidx;
            segmentsUnverifiedGrpOrder(usidx:usidx+length(uidx)-1,2) = u;
            sidx = sidx+length(idx);
            usidx = usidx+length(uidx);
        end
        Data.Graph.segInfo.segmentsGrpOrder = segmentsGrpOrder;
        Data.Graph.segInfo.segmentsUnverifiedGrpOrder = segmentsUnverifiedGrpOrder;
    end
    close(h);
% end


% --- Executes on button press in pushbutton_deleteSegment.
function pushbutton_deleteSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deleteSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

if isfield(Data.Graph,'segno')
    answer = questdlg(['Are you sure you want to delete segment ' num2str(Data.Graph.segno) '?'], 'Delete segment','No');
    if strcmp(answer,'Yes')
        if isfield(Data.Graph,'segmentstodelete')
            Data.Graph.segmentstodelete = [Data.Graph.segmentstodelete; Data.Graph.segno];
        else 
            Data.Graph.segmentstodelete = Data.Graph.segno;
        end
    end
end

draw(hObject, eventdata, handles);


% --------------------------------------------------------------------
function verification_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to verification_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

Vlst = find(Data.Graph.verifiedSegments==1);
UnVlst = find(Data.Graph.verifiedSegments==0);
figure;
subplot(1,2,1)
hist(Data.Graph.segInfo.segLen(Vlst),[0:1:max(Data.Graph.segInfo.segLen(Vlst))]);
title('Verified Segment Lengths (# nodes)');

subplot(1,2,2)
hist(Data.Graph.segInfo.segLen(UnVlst),[0:1:max(Data.Graph.segInfo.segLen(UnVlst))]);
title('Un-verified Segment Lengths (# nodes)');


% --------------------------------------------------------------------
function verification_deleteSelectedSegments_Callback(hObject, eventdata, handles)
% hObject    handle to verification_deleteSelectedSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

if isfield(Data.Graph,'segmentstodelete')
    segmentstodelete = Data.Graph.segmentstodelete;
    lstRemove = [];
    noteEndNodes = [];
    for u = 1:length(segmentstodelete)
        idx = find(Data.Graph.segInfo.nodeSegN == segmentstodelete(u));
        endnodes = Data.Graph.segInfo.segEndNodes(segmentstodelete(u),:);
        endnodes = endnodes(:);
        segs1 = find(Data.Graph.segInfo.segEndNodes(:,1) == endnodes(1) | Data.Graph.segInfo.segEndNodes(:,2) == endnodes(1));
        segs2 = find(Data.Graph.segInfo.segEndNodes(:,1) == endnodes(2) | Data.Graph.segInfo.segEndNodes(:,2) == endnodes(2));
        if length(segs1) > 1
            tsegs1 = setdiff(segs1,segmentstodelete);
            if ~isempty(tsegs1)
                idx = setdiff(idx,endnodes(1));
                if length(segs1) == 3
                    noteEndNodes = [noteEndNodes; endnodes(1)];
                end
                Data.Graph.segInfo.nodeSegN(endnodes(1)) = tsegs1(1);
            end
        end
        if length(segs2) > 1
            tsegs2 = setdiff(segs2,segmentstodelete);
            if ~isempty(tsegs2)
                idx = setdiff(idx,endnodes(2));
                if length(segs1) == 3
                    noteEndNodes = [noteEndNodes; endnodes(2)];
                end
                Data.Graph.segInfo.nodeSegN(endnodes(2)) = tsegs2(1);
            end
        end
        lstRemove = [lstRemove; idx];
        if isempty(idx)
              edgeidx = find((Data.Graph.edges(:,1) == endnodes(1) & Data.Graph.edges(:,2) == endnodes(2))|...
                  (Data.Graph.edges(:,1) == endnodes(2) & Data.Graph.edges(:,2) == endnodes(1)));
              Data.Graph.edges(edgeidx,:) = [];
              Data.Graph.segInfo.edgeSegN(edgeidx) = [];
        end
    end
    nNodes = size(Data.Graph.nodes,1);
    map = (1:nNodes)';
    map(lstRemove) = [];
    mapTemp = (1:length(map))';
    nodeMap = zeros(nNodes,1);
    nodeMap(map) = mapTemp;
    
    edgesNew = nodeMap(Data.Graph.edges);
    [ir,~] = find(edgesNew == 0);
    edgesNew(ir,:) = [];
    
   
    seglstRemove = Data.Graph.segmentstodelete;
    nSegments = size(Data.Graph.segInfo.segEndNodes,1);
    map = (1:nSegments)';
    map(seglstRemove) = [];
    mapTmp = (1:length(map))';
    segMap = zeros(nSegments,1);
    segMap(map) = mapTmp;
    
    Data.Graph.nodes(lstRemove,:) = [];
    Data.Graph.edges = edgesNew;
    Data.Graph.verifiedNodes(lstRemove) =[];
    Data.Graph.verifiedEdges(ir) =[];
    
    Data.Graph.segInfo.nodeGrp(lstRemove) = [];
    Data.Graph.segInfo.nodeSegN(lstRemove) = [];
    Data.Graph.segInfo.nodeSegN = segMap(Data.Graph.segInfo.nodeSegN);
    Data.Graph.segInfo.edgeSegN(ir) = [];
    Data.Graph.segInfo.edgeSegN = segMap(Data.Graph.segInfo.edgeSegN);
%     Data.Graph.segInfo.segNedges(seglstRemove) = [];
%     Data.Graph.segInfo.segLen(seglstRemove) = [];
%     Data.Graph.segInfo.segLen_um(seglstRemove) = [];
    Data.Graph.segInfo.segEndNodes(seglstRemove,:) = [];
    Data.Graph.segInfo.segEndNodes = nodeMap(Data.Graph.segInfo.segEndNodes); 
    Data.Graph.segInfo.segPos(seglstRemove,:) = [];
    
    Data.Graph.verifiedSegments(seglstRemove) = [];
    Data.Graph.segInfo.segCGrps(seglstRemove) = [];
 
    idx = find(ismember(Data.Graph.segInfo.unverifiedIdx,Data.Graph.segmentstodelete) == 1);
    Data.Graph.segInfo.unverifiedIdx(idx) = [];
    Data.Graph.segInfo.unverifiedIdx = segMap(Data.Graph.segInfo.unverifiedIdx);
    idx = find(ismember(Data.Graph.segInfo.unverifiedIdx3,Data.Graph.segmentstodelete) == 1);
    Data.Graph.segInfo.unverifiedIdx3(idx) = [];
    Data.Graph.segInfo.unverifiedIdx3 = segMap(Data.Graph.segInfo.unverifiedIdx3);
    idx = find(ismember(Data.Graph.segInfo.unverifiedIdx5,Data.Graph.segmentstodelete) == 1);
    Data.Graph.segInfo.unverifiedIdx5(idx) = [];
    Data.Graph.segInfo.unverifiedIdx5 = segMap(Data.Graph.segInfo.unverifiedIdx5);
    idx = find(ismember(Data.Graph.segInfo.unverifiedIdx10,Data.Graph.segmentstodelete) == 1);
    Data.Graph.segInfo.unverifiedIdx10(idx) = [];
    Data.Graph.segInfo.unverifiedIdx10 = segMap(Data.Graph.segInfo.unverifiedIdx10);
    
    
    idx = find(ismember(Data.Graph.segInfo.idx_end{1},Data.Graph.segmentstodelete) == 1);
    if ~isempty(Data.Graph.segInfo.idx_end{1})
        Data.Graph.segInfo.idx_end{1}(idx) = [];
        Data.Graph.segInfo.idx_end{1} = segMap( Data.Graph.segInfo.idx_end{1});
    end
    
    idx = find(ismember(Data.Graph.segInfo.idx_end{2},Data.Graph.segmentstodelete) == 1);
    if ~isempty(Data.Graph.segInfo.idx_end{2})
        Data.Graph.segInfo.idx_end{2}(idx) = [];
         Data.Graph.segInfo.idx_end{2} = segMap( Data.Graph.segInfo.idx_end{2});
    end
   
    idx = find(ismember(Data.Graph.segInfo.idx_end{3},Data.Graph.segmentstodelete) == 1);
    if ~isempty(Data.Graph.segInfo.idx_end{3})
        Data.Graph.segInfo.idx_end{3}(idx) = [];
        Data.Graph.segInfo.idx_end{3} = segMap( Data.Graph.segInfo.idx_end{3});
    end
    
    idx = find(ismember(Data.Graph.segInfo.idx_end{4},Data.Graph.segmentstodelete) == 1);
    if ~isempty(Data.Graph.segInfo.idx_end{4})
        Data.Graph.segInfo.idx_end{4}(idx) = [];
        Data.Graph.segInfo.idx_end{4} = segMap( Data.Graph.segInfo.idx_end{4});
    end  
    Data.Graph.segmentstodelete = [];
%     draw(hObject, eventdata, handles);

    % loops through the end nodes to make attached segments into one
    % segments and delete other
    segmentstodelete = [];
     for v = 1:length(noteEndNodes)
        Enode = noteEndNodes(v);
        segs = find(Data.Graph.segInfo.segEndNodes(:,1) == Enode | Data.Graph.segInfo.segEndNodes(:,2) == Enode);
        if length(segs) == 2 %length should be 2 but just in case...
            segmenttodelete = [segmentstodelete; segs(2)];
            nodes_idx = find(Data.Graph.segInfo.nodeSegN == segs(2));
            Data.Graph.segInfo.nodeSegN(nodes_idx) = segs(1);
            edges_idx = find(Data.Graph.segInfo.edgeSegN == segs(2));
            Data.Graph.segInfo.edgeSegN(edges_idx) = segs(1);
            endnodes1 = Data.Graph.segInfo.segEndNodes(segs(1),:);
            endnodes2 = Data.Graph.segInfo.segEndNodes(segs(2),:);
            endnodes = intersect(endnodes1,endnodes2);
            Data.Graph.segInfo.segEndNodes(segs(1),:) = endnodes;
        end
     end
    
     %  delete segments and update segInfo accordingly
     seglstRemove = Data.Graph.segmentstodelete;
     nSegments = length(Data.Graph.segInfo.segLen);
     map = (1:nSegments)';
     map(seglstRemove) = [];
     mapTmp = (1:length(map))';
     segMap = zeros(nSegments,1);
     segMap(map) = mapTmp;
     
     Data.Graph.segInfo.nodeSegN = segMap(Data.Graph.segInfo.nodeSegN);
     Data.Graph.segInfo.edgeSegN = segMap(Data.Graph.segInfo.edgeSegN);
     Data.Graph.segInfo.segNedges(seglstRemove) = [];
     Data.Graph.segInfo.segLen(seglstRemove) = [];
     Data.Graph.segInfo.segLen_um(seglstRemove) = [];
     Data.Graph.segInfo.segEndNodes(seglstRemove,:) = [];
     Data.Graph.segInfo.segPos(seglstRemove,:) = [];
     
     Data.Graph.verifiedSegments(seglstRemove) = [];
     Data.Graph.segInfo.segCGrps(seglstRemove) = [];
     
     %  Go to next segment
     pushbutton_nextSegment_Callback(hObject, eventdata, handles)
    
   
%     nodestoDelete = zeros(size(Data.Graph.nodes,1),1);
%     nodestoDelete(idx) = 1;
%     newNodes = [];
%     newnodeGrp = Data.Graph.segInfo.nodeGrp;
%     newnodeSegN = Data.Graph.segInfo.nodeSegN;
%     newedgeSegN = Data.Graph.segInfo.edgeSegN;
%     newverifiedNodes = [];
%     newverifiedEdges = Data.Graph.verifiedEdges;
%     newEdges = Data.Graph.edges;
%     verifiedSegmentsMap  = Data.Graph.verifiedSegments;
%     segmentno = 1;
%     for u = 1:length(Data.Graph.segInfo.segLen)
%         if sum(ismember(segmentstodelete,u)) == 0
%            verifiedSegmentsMap(u) = segmentno;
%            segmentno = segmentno+1;
%         else
%            verifiedSegmentsMap(u) = 0;
%         end
%     end
%     for u = 1:size(Data.Graph.nodes,1)
%         u
%         if nodestoDelete(u) == 1
%             idx = find(newEdges(:,1) == u | newEdges(:,2) == u);
%             newEdges(idx,:) = [];
%             newverifiedEdges(idx,:) = [];
%             newnodeGrp(idx) = [];
%             newnodeGrp(u) = [];
%             newnodeSegN(u) = [];
%             newedgeSegN(idx) = [];
%         else
%             newNodes = [newNodes; Data.Graph.nodes(u,:)];
%             newverifiedNodes = [newverifiedNodes; Data.Graph.verifiedNodes(u)];
%             idx = find(Data.Graph.edges(:,1) == u);
%             nodeno = size(newNodes,1);
%             newEdges(idx,1) = nodeno;
%              newedgeSegN(idx) = verifiedSegmentsMap(Data.Graph.segInfo.edgeSegN(idx));
%             idx = find(Data.Graph.edges(:,2) == u);
%             newEdges(idx,2) = nodeno;
%             newedgeSegN(idx) = verifiedSegmentsMap(Data.Graph.segInfo.edgeSegN(idx));
% %             newnodeGrp(u) = verifiedSegmentsMap(Data.Graph.segInfo.nodeGrp(u));
%             newnodeSegN(u) = verifiedSegmentsMap(Data.Graph.segInfo.nodeSegN(u));
%         end
%     end
%    
%     Data.Graph.nodes = newNodes;
%     Data.Graph.segInfo.nodeGrp = newnodeGrp;
%     Data.Graph.segInfo.nodeSegN = newnodeSegN;
%     Data.Graph.segInfo.edgeSegN = newedgeSegN;
%     Data.Graph.verifiedEdges = newverifiedEdges;
%     Data.Graph.verifiedSegments(Data.Graph.verifiedSegments == segmentstodelete) = [];
%     idx = find(ismember(Data.Graph.segInfo.unverifiedIdx,Data.Graph.segmentstodelete) == 1);
%     Data.Graph.segInfo.unverifiedIdx(idx) = [];
%     idx = find(ismember(Data.Graph.segInfo.unverifiedIdx3,Data.Graph.segmentstodelete) == 1);
%     Data.Graph.segInfo.unverifiedIdx3(idx) = [];
%     idx = find(ismember(Data.Graph.segInfo.unverifiedIdx5,Data.Graph.segmentstodelete) == 1);
%     Data.Graph.segInfo.unverifiedIdx5(idx) = [];
%     idx = find(ismember(Data.Graph.segInfo.unverifiedIdx10,Data.Graph.segmentstodelete) == 1);
%     Data.Graph.segInfo.unverifiedIdx10(idx) = [];
%     Data.Graph.segmentstodelete = [];
end


% --------------------------------------------------------------------
function Unverified_endSegments_Callback(hObject, eventdata, handles)
% hObject    handle to Unverified_endSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

checkmark = get(handles.Unverified_endSegments,'checked');
if strcmp(checkmark,'off')
    set(handles.Unverified_endSegments,'checked','on')
else
    set(handles.Unverified_endSegments,'checked','off')
end


% --- Executes on button press in pushbutton_makeNote.
function pushbutton_makeNote_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_makeNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

prompt = {'Enter note'};
title = 'Notes';
dims = [1 35];
answer = inputdlg(prompt,title,dims);
if ~isempty(answer)
    x1 = str2double(get(handles.edit_XcenterZoom,'string'));
    x2 = str2double(get(handles.edit_XwidthZoom,'string'));
    y1 = str2double(get(handles.edit_YcenterZoom,'string'));
    y2 = str2double(get(handles.edit_YwidthZoom,'string'));
    z1 = str2double(get(handles.edit_Zstartframe,'string'));
    z2 = str2double(get(handles.edit_ZMIP,'string'));
    if ~isfield(Data,'notes')
        Data.notes{1,1} = [x1 x2 y1 y2 z1 z2];
        Data.notes{1,2} = answer;
    else
        Data.notes{end+1,1} = [x1 x2 y1 y2 z1 z2];
        Data.notes{end,2} = answer;
    end
    if ~isfield(Data,'currentNote')
        Data.currentNote = 1;
    end
end

% --- Executes on button press in pushbutton_deleteNote.
function pushbutton_deleteNote_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deleteNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

if isfield(Data,'notes') && ~isempty(Data.notes) & isfield(Data,'currentNote')
    answer = questdlg('Are you sure you want to delete current note?', 'Delete last note','No');
    if strcmp(answer,'Yes')
        Data.notes(Data.currentNote,:) = [];
        Data.currentNote = min(Data.currentNote,size(Data.notes,1));
        if Data.currentNote == 0
            Data = rmfield(Data,'currentNote');
        end
    end
end



% % --- Executes on button press in pushbutton_clearNotes.
% function pushbutton_clearNotes_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton_clearNotes (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global Data
% 
% answer = questdlg('Are you sure you want to clear the notes?', 'Clear notes','No');
% if strcmp(answer,'Yes')
%     Data = rmfield(Data,'notes');
% end


% --- Executes on button press in checkbox_verifyNotes.
function checkbox_verifyNotes_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_verifyNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_verifyNotes
global Data
if get(handles.checkbox_verifyNotes,'Value') & isfield(Data,'notes') & ~isempty(Data.notes)
    set(handles.pushbutton_deleteNote,'Enable','on');
    set(handles.checkbox_verifySegments,'Value',0);
    checkbox_verifySegments_Callback(hObject, eventdata, handles)
    set(handles.pushbutton_prevSegment,'Enable','on');
    set(handles.pushbutton_nextSegment,'Enable','on');
    if isfield(Data,'currentNote')
        currentNote = Data.currentNote;
    else
        currentNote = 1;
    end
    Data.currentNote = currentNote;
    set(handles.text_segNumber,'String',['Note ' num2str(Data.currentNote) ' of ' num2str(size(Data.notes,1))]);
    vizInfo = Data.notes{currentNote,1};
    note = Data.notes{currentNote,2};
    set(handles.edit_XcenterZoom,'String',num2str(vizInfo(1)));
    set(handles.edit_XwidthZoom,'String',num2str(vizInfo(2)));
    set(handles.edit_YcenterZoom,'String',num2str(vizInfo(3)));
    set(handles.edit_YwidthZoom,'String',num2str(vizInfo(4)));
    set(handles.edit_Zstartframe,'String',num2str(vizInfo(5)));
    set(handles.edit_ZMIP,'String',num2str(vizInfo(6)));
    set(handles.edit_notes,'String',note);
    draw(hObject, eventdata, handles);
elseif ~get(handles.checkbox_verifyNotes,'Value')
    set(handles.pushbutton_deleteNote,'Enable','off');
    set(handles.pushbutton_prevSegment,'Enable','off');
    set(handles.pushbutton_nextSegment,'Enable','off');
end




function edit_notes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_notes as text
%        str2double(get(hObject,'String')) returns contents of edit_notes as a double

global Data

modified_note = get(handles.edit_notes,'String');
if get(handles.checkbox_verifyNotes,'Value') & isfield(Data,'notes') & ~isempty(Data.notes)
    if isfield(Data,'currentNote')
         Data.notes{Data.currentNote,2} = modified_note;
    end
end
checkbox_verifyNotes_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% function delete_segment(hObject, eventdata, handles)
% % This function deletes the segment and updates all the grapg infomration
% % accordingly
% 
% global Data



% --------------------------------------------------------------------
function verification_rmZeroSegments_Callback(hObject, eventdata, handles)
% hObject    handle to verification_rmZeroSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

for u = 1:size(Data.Graph.segInfo.segEndNodes,1)
    if isempty(find(Data.Graph.segInfo.nodeSegN == u))
        if isfield(Data.Graph,'segmentstodelete')
            Data.Graph.segmentstodelete = [Data.Graph.segmentstodelete; u];
        else
            Data.Graph.segmentstodelete = u;
        end
    end
end

verification_updateAll_Callback(hObject, eventdata, handles)




% --------------------------------------------------------------------
function getSegmentInfo_update_Callback(hObject, eventdata, handles)
% hObject    handle to getSegmentInfo_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

Data.Graph.segInfo = nodeGrps_vesSegment(Data.Graph.nodes, Data.Graph.edges);
segments = 1:size(Data.Graph.segInfo.segEndNodes,1);
segCGrps = zeros(1,size(Data.Graph.segInfo.segEndNodes,1));% group number for all segments
grpN = 1;
while ~isempty(segments)
    cSeg = segments(1);
    completedSegments = cSeg;
    segEndNodes = Data.Graph.segInfo.segEndNodes(cSeg,:);
    cdeletednodes = [];
    while ~isempty(segEndNodes)
        cEndnode = segEndNodes(end);
%         u1 = segEndNodes(1);
%         u2 = segEndNodes(2);
%         nodesegments = find(Data.Graph.segInfo.nodeSegN(cEndnode));
        seg1 = find((Data.Graph.segInfo.segEndNodes(:,1) == cEndnode) | (Data.Graph.segInfo.segEndNodes(:,2) == cEndnode));
%         seg2 = find((Data.Graph.segInfo.segEndNodes(:,1) == u2) | (Data.Graph.segInfo.segEndNodes(:,2) == u2));
        cSeg = unique([cSeg ; seg1]);
        tempseg = unique(setdiff(seg1,completedSegments)); 
        cdeletednodes = [cdeletednodes segEndNodes(end)];
        segEndNodes(end) = [];
        for u = 1:length(tempseg)
            tempEndNodes = Data.Graph.segInfo.segEndNodes(tempseg(u),:);
            segEndNodes = setdiff(unique([segEndNodes; tempEndNodes']),cdeletednodes);
        end
        temparray = ismember(segments,cSeg);
        completedSegments = unique([completedSegments; cSeg]);
        idx = find(temparray == 1);
        segCGrps(cSeg) = grpN;
        segments(idx) = [];
    end
    grpN = grpN+1;
end
Data.Graph.segInfo.segCGrps = segCGrps;

% --------------------------------------------------------------------
function getSegmentInfo_display_Callback(hObject, eventdata, handles)
% hObject    handle to getSegmentInfo_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
if isfield(Data.Graph.segInfo,'segCGrps')
    for u =1:29 
        L = length(find(Data.Graph.segInfo.segCGrps==u)); 
        disp(['Group ' num2str(u) ' has ' num2str(L) ' segments']) 
    end
end


% --------------------------------------------------------------------
function Verifications_Groups_Callback(hObject, eventdata, handles)
% hObject    handle to Verifications_Groups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function Groups_All_Callback(hObject, eventdata, handles)
% hObject    handle to Groups_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Groups_All,'checked','on');
set(handles.Group_groupWithMostSegments,'checked','off');
set(handles.Groups_groupswithleastsegments,'checked','off');
set(handles.AllSegments_lessthan3nodes,'Enable','on');
set(handles.AllSegments_lessthan5nodes,'Enable','on');
set(handles.AllSegments_lessthan10nodes,'Enable','on');
set(handles.AllSegments_endSegments,'Enable','on');
set(handles.unverifedlessthan3Nodes,'Enable','on');
set(handles.unverifedlessthan5Nodes,'Enable','on');
set(handles.unverifedlessthan10Nodes,'Enable','on');
set(handles.Unverified_endSegments,'Enable','on');

% --------------------------------------------------------------------
function Group_groupWithMostSegments_Callback(hObject, eventdata, handles)
% hObject    handle to Group_groupWithMostSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
set(handles.Groups_All,'checked','off');
set(handles.Group_groupWithMostSegments,'checked','on');
set(handles.Groups_groupswithleastsegments,'checked','off');
Data.Graph.segnoMS = 1;
set(handles.AllSegments_lessthan3nodes,'Enable','off');
set(handles.AllSegments_lessthan5nodes,'Enable','off');
set(handles.AllSegments_lessthan10nodes,'Enable','off');
set(handles.AllSegments_endSegments,'Enable','off');
set(handles.unverifedlessthan3Nodes,'Enable','off');
set(handles.unverifedlessthan5Nodes,'Enable','off');
set(handles.unverifedlessthan10Nodes,'Enable','off');
set(handles.Unverified_endSegments,'Enable','off');
if strcmp(get(handles.verification_allSegments,'checked'),'on')
    u = Data.Graph.segnoMS;
    %                 u = min(u+1,length(Data.Graph.segInfo.segmentsGrpOrder));
%     Data.Graph.segnoMS = min(Data.Graph.segnoMS+1,length(Data.Graph.segInfo.segmentsGrpOrder));
    u = Data.Graph.segInfo.segmentsGrpOrder(Data.Graph.segnoMS);
else
    u = Data.Graph.segnoMS;
    u = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(Data.Graph.segnoMS);
end

Data.Graph.segno = u;
endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
seg_nodes = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);

% Current segment dimensions
Zmin = min(Data.Graph.nodes(seg_nodes,3));
Zmax = max(Data.Graph.nodes(seg_nodes,3));
Xmin = min(Data.Graph.nodes(seg_nodes,1));
Xmax = max(Data.Graph.nodes(seg_nodes,1));
Ymin = min(Data.Graph.nodes(seg_nodes,2));
Ymax = max(Data.Graph.nodes(seg_nodes,2));

set(handles.edit_XcenterZoom,'String',num2str(max(round(Xmin+(Xmax-Xmin)/2),1)));
set(handles.edit_YcenterZoom,'String',num2str(max(round(Ymin+(Ymax-Ymin)/2),1)));
set(handles.edit_Zstartframe,'String',num2str(max(round(Zmin-10),1)));

set(handles.edit_XwidthZoom,'String',num2str(max(round(Xmax-Xmin+20),1)));
set(handles.edit_YwidthZoom,'String',num2str(max(round(Ymax-Ymin+20),1)));
set(handles.edit_ZMIP,'String',num2str(max(round(Zmax-Zmin+20),1)));

draw(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Groups_groupswithleastsegments_Callback(hObject, eventdata, handles)
% hObject    handle to Groups_groupswithleastsegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data 

set(handles.Groups_All,'checked','off');
set(handles.Group_groupWithMostSegments,'checked','off');
set(handles.Groups_groupswithleastsegments,'checked','on');
Data.Graph.segnoLS = 0;
set(handles.AllSegments_lessthan3nodes,'Enable','off');
set(handles.AllSegments_lessthan5nodes,'Enable','off');
set(handles.AllSegments_lessthan10nodes,'Enable','off');
set(handles.AllSegments_endSegments,'Enable','off');
set(handles.unverifedlessthan3Nodes,'Enable','off');
set(handles.unverifedlessthan5Nodes,'Enable','off');
set(handles.unverifedlessthan10Nodes,'Enable','off');
set(handles.Unverified_endSegments,'Enable','off');

if strcmp(get(handles.verification_allSegments,'checked'),'on')
    L = length(Data.Graph.segInfo.segmentsGrpOrder);
    u = max(L-Data.Graph.segnoLS,1);
    u = Data.Graph.segInfo.segmentsGrpOrder(u);
else
    L = length(Data.Graph.segInfo.segmentsUnverifiedGrpOrder);
    u = max(L-Data.Graph.segnoLS,1);
    u = Data.Graph.segInfo.segmentsUnverifiedGrpOrder(u);
end

Data.Graph.segno = u;
endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
seg_nodes = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);

% Current segment dimensions
Zmin = min(Data.Graph.nodes(seg_nodes,3));
Zmax = max(Data.Graph.nodes(seg_nodes,3));
Xmin = min(Data.Graph.nodes(seg_nodes,1));
Xmax = max(Data.Graph.nodes(seg_nodes,1));
Ymin = min(Data.Graph.nodes(seg_nodes,2));
Ymax = max(Data.Graph.nodes(seg_nodes,2));

set(handles.edit_XcenterZoom,'String',num2str(max(round(Xmin+(Xmax-Xmin)/2),1)));
set(handles.edit_YcenterZoom,'String',num2str(max(round(Ymin+(Ymax-Ymin)/2),1)));
set(handles.edit_Zstartframe,'String',num2str(max(round(Zmin-10),1)));

set(handles.edit_XwidthZoom,'String',num2str(max(round(Xmax-Xmin+20),1)));
set(handles.edit_YwidthZoom,'String',num2str(max(round(Ymax-Ymin+20),1)));
set(handles.edit_ZMIP,'String',num2str(max(round(Zmax-Zmin+20),1)));

draw(hObject, eventdata, handles);
% --------------------------------------------------------------------
function AllSegments_lessthan3nodes_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_lessthan3nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.AllSegments_lessthan3nodes,'checked','on');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','on');
set(handles.AllSegments_nBG3,'checked','off');
set(handles.AllSegments_loops,'checked','off');

set(handles.unverified,'checked','off');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','off');

% --------------------------------------------------------------------
function AllSegments_lessthan5nodes_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_lessthan5nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','on');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','on');
set(handles.AllSegments_nBG3,'checked','off');
set(handles.AllSegments_loops,'checked','off');

set(handles.unverified,'checked','off');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','off');


% --------------------------------------------------------------------
function AllSegments_lessthan10nodes_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_lessthan10nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','on');
set(handles.AllSegments_All,'checked','off');
set(handles.verification_allSegments,'checked','on');
set(handles.AllSegments_nBG3,'checked','off');
set(handles.AllSegments_loops,'checked','off');

set(handles.unverified,'checked','off');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','off');


% --------------------------------------------------------------------
function AllSegments_All_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.AllSegments_lessthan3nodes,'checked','off');
set(handles.AllSegments_lessthan5nodes,'checked','off');
set(handles.AllSegments_lessthan10nodes,'checked','off');
set(handles.AllSegments_All,'checked','on');
set(handles.verification_allSegments,'checked','on');
set(handles.AllSegments_nBG3,'checked','off');
set(handles.AllSegments_loops,'checked','off');

set(handles.unverified,'checked','off');
set(handles.unverifedlessthan3Nodes,'checked','off');
set(handles.unverifedlessthan5Nodes,'checked','off');
set(handles.unverifedlessthan10Nodes,'checked','off');
set(handles.unverifedAllNodes,'checked','off');

% --------------------------------------------------------------------
function AllSegments_endSegments_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_endSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

checkmark = get(handles.AllSegments_endSegments,'checked');
if strcmp(checkmark,'off')
    set(handles.AllSegments_endSegments,'checked','on')
else
    set(handles.AllSegments_endSegments,'checked','off')
end



function edit_segmentNumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_segmentNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_segmentNumber as text
%        str2double(get(hObject,'String')) returns contents of edit_segmentNumber as a double

global Data
segment_number = str2double(get(handles.edit_segmentNumber,'string'));
if ~isnan(segment_number)
    Data.Graph.segno = round(segment_number);
else
    set(handles.edit_segmentNumber,'string',num2str(Data.Graph.segno));
end

endNodes = Data.Graph.segInfo.segEndNodes(Data.Graph.segno,:);
seg_nodes = unique([find(Data.Graph.segInfo.nodeSegN == Data.Graph.segno);endNodes(:)]);
  
Zmin = min(Data.Graph.nodes(seg_nodes,3));
Zmax = max(Data.Graph.nodes(seg_nodes,3));
Xmin = min(Data.Graph.nodes(seg_nodes,1));
Xmax = max(Data.Graph.nodes(seg_nodes,1));
Ymin = min(Data.Graph.nodes(seg_nodes,2));
Ymax = max(Data.Graph.nodes(seg_nodes,2));

set(handles.edit_XcenterZoom,'String',num2str(max(round(Xmin+(Xmax-Xmin)/2),1)));
set(handles.edit_YcenterZoom,'String',num2str(max(round(Ymin+(Ymax-Ymin)/2),1)));
set(handles.edit_Zstartframe,'String',num2str(max(round(Zmin-10),1)));

set(handles.edit_XwidthZoom,'String',num2str(max(round(Xmax-Xmin+20),1)));
set(handles.edit_YwidthZoom,'String',num2str(max(round(Ymax-Ymin+20),1)));
set(handles.edit_ZMIP,'String',num2str(max(round(Zmax-Zmin+20),1)));

    
draw(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_segmentNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_segmentNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_addEdge.
function radiobutton_addEdge_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_addEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_addEdge
draw(hObject, eventdata, handles);

% --- Executes on button press in radiobutton_selectSegment.
function radiobutton_selectSegment_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_selectSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_selectSegment
draw(hObject, eventdata, handles);


% --------------------------------------------------------------------
function segmentation_loadSegmentation_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_loadSegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data

[filename,pathname] = uigetfile({'*.mat;*.tiff;*.tif'},'Please select the Angiogram Data');
h = waitbar(0,'Please wait... loading the data');
[~,~,ext] = fileparts(filename);
if strcmp(ext,'.mat')
    temp = load([pathname filenmae]);
    fn = fieldnames(temp);
    Data.segangio = temp.(fn{1});
elseif strcmp(ext,'.tiff') || strcmp(ext,'.tif')
    info = imfinfo([pathname filename]);
    for u = 1:length(info)
        if u == 1
            temp = imread([pathname filename],1);
            angio = zeros([length(info) size(temp)]);
            angio(u,:,:) = temp;
        else
            angio(u,:,:) = imread([pathname filename],u);
        end
    end
    Data.segangio = angio;
end
Data.segangio(Data.segangio > 1) = 1;
close(h);
draw(hObject, eventdata, handles);


% --- Executes on button press in radiobutton_XYview.
function radiobutton_XYview_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_XYview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_XYview
set(handles.radiobutton_XYview,'value',1);
set(handles.radiobutton_XZview,'value',0);
set(handles.radiobutton_YZview,'value',0);
draw(hObject, eventdata, handles);

% --- Executes on button press in radiobutton_XZview.
function radiobutton_XZview_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_XZview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_XZview
set(handles.radiobutton_XZview,'value',1);
set(handles.radiobutton_XYview,'value',0);
set(handles.radiobutton_YZview,'value',0);
draw(hObject, eventdata, handles);

% --- Executes on button press in radiobutton_YZview.
function radiobutton_YZview_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_YZview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_YZview
set(handles.radiobutton_YZview,'value',1);
set(handles.radiobutton_XZview,'value',0);
set(handles.radiobutton_XYview,'value',0);
draw(hObject, eventdata, handles);


% --------------------------------------------------------------------
function AllSegments_nBG3_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_nBG3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.AllSegments_nBG3,'checked'),'on')
    set(handles.AllSegments_nBG3,'checked','off');
else
    set(handles.AllSegments_nBG3,'checked','on');
    set(handles.AllSegments_loops,'checked','off');
end

function select_points(handles)

disp('here');


% --------------------------------------------------------------------
function AllSegments_loops_Callback(hObject, eventdata, handles)
% hObject    handle to AllSegments_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.AllSegments_loops,'checked'),'on')
    set(handles.AllSegments_loops,'checked','off');
else
    set(handles.AllSegments_loops,'checked','on');
    set(handles.AllSegments_nBG3,'checked','off');
end
