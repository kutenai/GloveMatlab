classdef GyroGloveIMUPacket < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        state
        type
        ID
        bytes
        CRC
        WD
        data = []
    end
    
    methods
        function obj = GyroGloveIMUPacket()
            obj.state = PkState.sStart;
        end
        
        function getChars(obj,ser)
            
            if ser.BytesAvailable
                switch(obj.state)
                    case PkState.sStart
                        c = fread(ser,1);
                        if c == 'S'
                            obj.state = PkState.sFndN;
                        end
                    case PkState.sFndN
                        c = fread(ser,1);
                        if c == 'N'
                            obj.state = PkState.sFndP;
                        else
                            obj.stae = PkState.sStart;
                        end
                    case PkState.sFndP
                        c = fread(ser,1);
                        if c == 'P'
                            obj.state = PkState.sPkType;
                        else
                            obj.state = PkState.sStart;
                        end
                    case PkState.sPkType
                        c = fread(ser,1);
                        obj.type = int32(c);
                        obj.state = PkState.sPkID;
                    case PkState.sPkID
                        c = fread(ser,1);
                        obj.ID = int32(c);
                        obj.state = PkState.sPkSize;
                    case PkState.sPkSize
                        c = fread(ser,1);
                        obj.bytes = double(c);
                        obj.state = PkState.sPkData;
                    case PkState.sPkData
                        d = fread(ser,obj.bytes/2,'int16');
                        obj.data = swapbytes(int16(d));
                        obj.state = PkState.sPkCRC;
                    case PkState.sPkCRC
                        obj.WD = fread(ser,1);
                        obj.CRC = swapbytes(uint16(fread(ser,1,'uint16')));
                        obj.state = PkState.sPkDone;
                end
            end
        end
        
        function v = validPacket(obj)
            if obj.state == PkState.sPkDone
                v = true;
            else
                v = false;
            end
        end
                
    end
    
end

