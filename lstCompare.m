% lst compare


[EEG,ERP,erns] = altairLstPreproc(fName,binListerPath,channelLocationFile);

x=EEG.data;
ern1=squeeze(x(:,:,1));
ern2=squeeze(x(:,:,2));

chanSel=32;

e1=ern1(chanSel,:);

e2=ern2(chanSel,:);

t=linspace(-200,1000,length(e1));

figureHandle2=figure;
los=e1;
win=e2;
plot(t,(los))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(t,(win))
legend('Loss','Win')
hold off;

clear EEG;
clear ERP;
clear erns;


[EEG,ERP,erns] = altairDoorsPreproc(fName,binListerPath,channelLocationFile);

x=EEG.data;
ern1=squeeze(x(:,:,1));
ern2=squeeze(x(:,:,2));

chanSel=32;

e1=ern1(chanSel,:);

e2=ern2(chanSel,:);

t=linspace(-200,1000,length(e1));

figureHandle2=figure;
los=e1;
win=e2;
plot(t,(los))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(t,(win))
legend('Loss','Win')
hold off;

