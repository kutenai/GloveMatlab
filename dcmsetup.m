clear all;

%dataColl = loadallimu('DataCollection/');
testdata = load('DataCollection/InitializeRun_Ver1.mat')
g = GloveIMU;

% The data and ranges are specific to this dataset..
g.setData(testdata);
dcmAlignRange = [2000 2800;3400 3900;4300 4900];
dcmCourseRange = [500 900];
%g.dcmAlignAll(dcmCourseRange,dcmAlignRange);
g.dcmAlignAcc(dcmAlignRange);
[a,C] = g.courseAlignHand(dcmCourseRange)
g.calcDCMFromAccData;

g.EulerAngles