clear all; clc;
% map & grid file
sl=shaperead('bayall_river.shp'); 
sl_jmx=sl(2).X; % James shoreline
sl_jmy=sl(2).Y; 
sl_bayx=sl(1).X;  % Bay shoreline
sl_bayy=sl(1).Y;
% 
fname = 'hgrid.gr3'; 
fid=fopen(fname,'r'); char=fgetl(fid); tmp1=str2num(fgetl(fid));fclose(fid);ne=fix(tmp1(1)); np=fix(tmp1(2));
fid=fopen(fname); c1=textscan(fid,'%d%f%f%f',np,'headerLines',2);fclose(fid);
x=c1{2}(:); y=c1{3}(:); bathy=c1{4}(:);
% 
bnd=load("bnd_node.txt"); 
bnd=unique(bnd,'stable'); 
bndx=x(bnd); bndy=y(bnd);
%% particle tracking results
load path.mat;
tbegin=datenum(2019,1,1); 
t0=path.time; 
date0=datestr(t0+tbegin);
%% 
for tplt=4 % 1:5
    close all
    %---- satellite-derived chla
    if tplt==1;fn='sentinel-3b.2020212.0730.1506C.L3.CB3.v950V20193_1_2.chl_gil_rhos.tif';
    elseif tplt==2;fn='sentinel-3b.2020216.0803.1502C.L3.CB3.v950V20193_1_2.chl_gil_rhos.tif';
    elseif tplt==3;fn='sentinel-3a.2020217.0804.1515C.L3.CB3.v950V20193_1_2.chl_gil_rhos.tif';
    elseif tplt==4;fn='sentinel-3a.2020218.0805.1449C.L3.CB3.v950V20193_1_2.chl_gil_rhos.tif';
    else fn='sentinel-3b.2020219.0806.1524C.L3.CB3.v950V20193_1_2.chl_gil_rhos.tif';
    end
    [A,R,cmp]=readgeoraster(fn); Xlim=R.XWorldLimits; Ylim=R.YWorldLimits;
    true_val_tmp=double(A); true_val_tmp(true_val_tmp>250)=nan;
    true_chla=13.46374./(275./true_val_tmp-1);  % true chla
    dx=300; dy=300; XX=[Xlim(1):dx:Xlim(2)]; YY=[Ylim(1):dy:Ylim(2)];
    Xcnt1=XX(1:end-1)+dx/2; Ycnt1=YY(1:end-1)+dy/2; % center of each pixel
    [Xcnt,Ycnt]=meshgrid(Xcnt1,Ycnt1);
    %
    figure('visible','on'); set(gcf,'position',[100 100 600 600])
    pcolor(Xcnt,Ycnt,flipud(true_chla)); shading flat;  hold on
    plot(sl_bayx,sl_bayy,'k');plot(sl_jmx,sl_jmy,'k');plot(bndx,bndy,'k')
    colormap(flipud(othercolor('Spectral11'))); colorbar; caxis([0 50])
    title([fn(1:24),'-chla']); set(gca,'fontsize',12)

    %---- satellite RBD
    if tplt==1;fn='sentinel-3b.2020212.0730.1506C.L3.CB3.v950V20193_1_2_x0-1.rbd_rhos.tif';
    elseif tplt==2;fn='sentinel-3b.2020216.0803.1502C.L3.CB3.v950V20193_1_2_x0-1.rbd_rhos.tif';
    elseif tplt==3;fn='sentinel-3a.2020217.0804.1515C.L3.CB3.v950V20193_1_2_x0-1.rbd_rhos.tif';
    elseif tplt==4;fn='sentinel-3a.2020218.0805.1449C.L3.CB3.v950V20193_1_2_x0-1.rbd_rhos.tif';
    else fn='sentinel-3b.2020219.0806.1524C.L3.CB3.v950V20193_1_2_x0-1.rbd_rhos.tif';
    end
    [A,R,cmp]=readgeoraster(fn); true_val_tmp=double(A); true_val_tmp(true_val_tmp>250)=nan;
    true_rbd=10.^(true_val_tmp/150-4); 
    %
    figure('visible','on'); set(gcf,'position',[100 100 600 600])
    pcolor(Xcnt,Ycnt,flipud(true_rbd)); shading flat;
    colormap(flipud(othercolor('Spectral11'))); h=colorbar; title(h,'rbd'); hold on
    plot(sl_bayx,sl_bayy,'k');plot(sl_jmx,sl_jmy,'k');plot(bndx,bndy,'k')
    title([fn(1:24),'-rbd']); set(gca,'fontsize',12)

    %---- satellite-derived chla to be compared with particles' results
    chla_sat_cmp=flipud(true_chla);
    chla_sat_cmp(flipud(true_rbd)<2e-4)=nan;
    chla_sat_cmp(isnan(flipud(true_rbd)))=nan;
    figure('visible','on');set(gcf,'position',[100 100 600 600])
    pcolor(Xcnt,Ycnt,chla_sat_cmp);shading flat; hold on;
    colormap(flipud(othercolor('Spectral11'))); colorbar;
    caxis([0 100]);
    xmin=3.6e5; xmax=4.5e5; ymin=4.06e6; ymax=4.12e6;
    xlim([xmin xmax]);ylim([ymin ymax])
    plot(sl_bayx,sl_bayy,'k');plot(sl_jmx,sl_jmy,'k');plot(bndx,bndy,'k')
    title('satellite-chla based on rbd>2e-4'); set(gca,'fontsize',12)

    %%---------------------------------------------------------------------
    %%---------------------------------------------------------------------
    % plot particle tracking results against satellite
    % fisrt find the best-match between 10:00-18:00
    tb_all= [308,500,548,596,644]; window=17; % searching between 10:00-18:00
    clear par_2_pixel_chla_allt chla_par_cmp_allt
    for cnt=1:window
        tt=tb_all(tplt)+cnt-1;
        clear chla_par_cmp par_2_pixel_chla par_2_pixel_chla_used
        xpar=path.x(:,tt); ypar=path.y(:,tt); chla_par=path.chla(:,tt); zpar=path.z(:,tt);
        dep=-1; chla_par(zpar<dep)=0; % depth>1m, near surface
        Xmin=min(XX); Ymin=min(YY);
        % find the pixel index where the particle stays
        tmp1=ceil((xpar-Xmin)/300); tmp2=ceil((ypar-Ymin)/300); tmp2(tmp2<=0)=1;
        % sum all particle-chla in the same pixel
        par_2_pixel_chla=zeros(size(Xcnt));
        for i=1:length(tmp1)
            par_2_pixel_chla(tmp2(i),tmp1(i))=par_2_pixel_chla(tmp2(i),tmp1(i))+...
                chla_par(i);
        end
        par_2_pixel_chla(par_2_pixel_chla==0)=nan;
        par_2_pixel_chla_allt(:,:,cnt)=par_2_pixel_chla; % save the chla every half hour (10:00-18:00)
    end
    %%---------------
    tmp_sat=flipud(true_chla);
    clear gap
    for cnt=1:window
        clear gap1
        tmp_par=par_2_pixel_chla_allt(:,:,cnt);
        gap1=abs(tmp_par-tmp_sat); 
        gap(:,:,cnt)=gap1;
    end
    %
    clear a b
    for i=1:1302
        for j=1:1108
            tmp=squeeze(gap(i,j,:)); 
            [a(i,j),b(i,j)]=min(tmp);
        end
    end
    %
    clear par_2_pixel_chla_used  % best-match results
    for i=1:1302
        for j=1:1108
            par_2_pixel_chla_used(i,j)=par_2_pixel_chla_allt(i,j,b(i,j));
        end
    end

    %%---------------------------------------------------------------------
    % plot the time when model and satellite fit the most
    figure;
    b(b<=1)=nan; pcolor(Xcnt,Ycnt,b); shading flat;
    cb=colorbar;set(cb,'position',[0.8,0.15,0.02,0.5])
    cb.Ticks=[1,3,5,7,9,11,13,15,17];
    cb.TickLabels={'10:00','11:00','12:00','13:00','14:00','15:00',...
        '16:00','17:00','18:00'}
    hold on
    plot(bndx,bndy,'k');plot(sl_jmx,sl_jmy,'k');plot(sl_bayx,sl_bayy,'k')
    xmin=3.6e5; xmax=4.6e5; ymin=4.06e6; ymax=4.13e6;
    xlim([xmin xmax]); ylim([ymin ymax])
    tmp_color=othercolor('Greys9'); tmp_color=tmp_color(1:18:256,:);
    colormap(tmp_color)
    title('Time when model and satellite fit the most')
    set(gca,'fontsize',15); 
%     title(date0(tt,1:11));
    % print('-dpng','-r200',['Best-match-time-',date0(tt,1:11)])

    %%---------------------------------------------------------------------
    % plot particle-chla from best-match, satellite-derived chla & RBD
    figure; set(gcf,'position',[100 100 1200 300])
    subplot(1,3,1)
    par_2_pixel_chla_used(par_2_pixel_chla_used<0.4)=nan;
    pcolor(Xcnt,Ycnt,par_2_pixel_chla_used); shading flat; hold on
    colormap(flipud(othercolor('Spectral11'))); 
    caxis([0 50]);
    h=colorbar; set(h,'position',[0.3,0.2,0.005,0.1])
    plot(bndx,bndy,'k');plot(sl_jmx,sl_jmy,'k');plot(sl_bayx,sl_bayy,'k')
    xmin=3.6e5; xmax=4.6e5; ymin=4.06e6; ymax=4.13e6;
    xlim([xmin xmax]); ylim([ymin ymax])
    title([date0(tb_all(tplt),1:11)])
    set(gca,'fontsize',15)

    % satellite-derived chla
    subplot(1,3,2);pcolor(Xcnt,Ycnt,flipud(true_chla));shading flat; hold on
    colormap(flipud(othercolor('Spectral11'))); 
    caxis([0 50]); title('Satellite-derived Chla')
    xlim([xmin xmax]);ylim([ymin ymax])
    plot(sl_bayx,sl_bayy,'k');plot(sl_jmx,sl_jmy,'k');plot(bndx,bndy,'k')
    set(gca,'fontsize',15)

    % RBD
    subplot(1,3,3);pcolor(Xcnt,Ycnt,flipud(true_rbd));shading flat; hold on
    tmp_color=flipud(othercolor('Spectral11'));tmp_color(1,:)=[0 0 0];
    colormap(tmp_color); 
    h=colorbar; set(h,'position',[0.92 0.2,0.005,0.1]);
    title('RBD')
    xlim([xmin xmax]);ylim([ymin ymax])
    plot(sl_bayx,sl_bayy,'k');plot(sl_jmx,sl_jmy,'k');plot(bndx,bndy,'k')
    set(gca,'fontsize',15)
    % print('-dpng','-r200',['Calib-all-',date0(tt,1:11)])

    %%---------------------------------------------------------------------
    % plot statistical comparison
    figure; set(gcf,'position',[100 100 900 300])
    subplot(1,2,1)
    for cnt=1:window-1
        chla_par_cmp=squeeze(par_2_pixel_chla_allt(:,:,cnt));
        chla_par_cmp(flipud(true_rbd)<2e-4)=nan;
        chla_par_cmp(isnan(flipud(true_rbd)))=nan;

        chla_par_cmp_clear=chla_par_cmp(~isnan(chla_par_cmp));        
        A=chla_par_cmp_clear;
        h=cdfplot(A);
        set(h,'color',[255 190 190]/255,'LineWidth',1,'linestyle','-')
        hold on;
    end
    chla_par_cmp=par_2_pixel_chla_used;
    chla_par_cmp(flipud(true_rbd)<2e-4)=nan;
    chla_par_cmp(isnan(flipud(true_rbd)))=nan;
    chla_par_cmp_clear=chla_par_cmp(~isnan(chla_par_cmp)&(~isnan(chla_sat_cmp)));
    chla_sat_cmp_clear=chla_sat_cmp(~isnan(chla_par_cmp)&(~isnan(chla_sat_cmp)));
    
    A=chla_par_cmp_clear;
    B=chla_sat_cmp_clear;
    C=B(~isnan(B));
    
    h=cdfplot(C); set(h,'color','k','LineWidth',2); hold on
    h=cdfplot(A); set(h,'color','r','LineWidth',2)
    grid on; grid minor;
    ylabel('Cumulative distribution function')
    title(date0(tt,1:11)); set(gca,'fontsize',15)
    xlabel('Chl-a (mg/m^3)')
    xlim([0 150])
    %
    subplot(1,2,2);
    h1=histogram(A,'FaceColor','r'); hold on;
    h1.BinWidth=2; 
    h2=histogram(C,'FaceColor','k');grid on
    h2.BinWidth=2;
    title(date0(tt,1:11));legend('Model','Satellite')
    xlabel('Chl-a (mg/m^3)'); ylabel('Counts')
    xlim([0 150]);set(gca,'fontsize',15); grid on; grid minor
    % print('-dpng','-r200',['Calib-stat-',date0(tt,1:11)])

end


