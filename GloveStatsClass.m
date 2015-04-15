classdef GloveStatsClass < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fdir
        T  = 0.01;
        g
        
        data
        full
        half
        
    end
    
    methods
        function obj = GloveStatsClass(dir)
            if nargin > 0
                obj.fdir = dir;
            else
                obj.fdir = 'GloveChar/Run1';
            end
            obj.g = GloveData;
            obj.full = struct;
            obj.half = struct;
            obj.LoadData();
        end
        
        function CalcStats(obj)
            dvals = size(obj.data,2);
            obj.full.velocity = zeros(dvals,18);
            obj.full.mean = zeros(1,18);
            obj.full.mvelocity = zeros(dvals,18);
            obj.full.variance = zeros(1,18);
            for k = 1:dvals
                acc = obj.data{k};
                obj.full.velocity(k,:) = obj.T*trapz(acc);
            end
            obj.full.mean = mean(obj.full.velocity);
            for x = 1:dvals
                obj.full.mvelocity(x,:) = obj.full.velocity(x,:) - obj.full.mean;
            end
            obj.full.variance = var(obj.full.mvelocity);
        end
                
        function LoadData(obj)
            
            files = dirc([obj.fdir '/*.mat'],'f','n');

            nFiles = size(files,1);

            skip = 100;
            rows = size(files,1);
            obj.data = {};

            for k = 1:size(files,1)
                f = files(k);
                t = load([obj.fdir '/' f{1}]);
                % Some of the newer structures include a .Name and a .T
                % value. .Name specifies the name directly, older structures
                % just had the first field be the data.. I could not specify
                % anyting else, like the period.
                if isfield(t,'Data')
                    data = t.Data;
                else
                    fn = fieldnames(t);
                    field = fn{1};
                    data = getfield(t,field);
                end

                if isfield(t,'T')
                    T = t.T;
                else
                    % This is the default for old data that did not specify
                    % otherwise
                    T = 1/180;
                end

                obj.data{k} = data(skip+1:size(data,1),obj.g.accIndexes)*obj.g.accFactor*9.8;
            end
            
        end
    end
    
end

