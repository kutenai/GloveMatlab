clear all;

dataColl = loadallimu('DataCollection/');
g = GloveIMU;

% The data and ranges are specific to this dataset..
g.setData(dataColl.InitializeRun_Ver1.data,dataColl.InitializeRun_Ver1.T);
g.dcmAlignAcc([2000 2800;3400 3900;4300 4900]);
g.calcDCMFromAccData;

g.EulerAngles