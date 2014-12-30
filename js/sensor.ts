///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />

class Sensor extends Device {
    private port: string;
    private sensorDeviceDir = '/sys/class/lego-sensor/';

    private sensorTypes : string[] = [];

    private _deviceIndex: number = -1;
    get deviceIndex(): number {
        return this._deviceIndex;
    }

    constructor(port: string, types: string[], i2cAddress?: string) {
        super();

        this.port = port;
        var rootPath: string;

        try {
            var availableDevices = fs.readdirSync(this.sensorDeviceDir);
            for (var i in availableDevices) {
                var file = availableDevices[i];

                rootPath = path.join(this.sensorDeviceDir, file);

                var portName = fs.readFileSync(
                        path.join(rootPath, "port_name")
                    ).toString().trim();

                var typeName = fs.readFileSync(
                        path.join(rootPath, "name")
                    ).toString().trim();

                var i2cDeviceAddress = fs.readFileSync(
                        path.join(rootPath, "address")
                    ).toString().trim();

                var satisfiesCondition = (
                        (port == ports.INPUT_AUTO)
                        || (port == undefined)
                        || (portName === port)
                    ) && (
                        (types == undefined || types == [])
                        || types.indexOf(typeName) != -1
                    ) && (
                        (i2cAddress == undefined)
                        || (i2cAddress == i2cDeviceAddress)
                    );
                
                if (satisfiesCondition) {
                    this._deviceIndex = Number(file.substring('sensor'.length));
                    break;
                }
            }

            if (this.deviceIndex == -1) {
                this.connected = false;
                return;
            }
        }

        catch (e) {
            console.log(e);
            this.connected = false;
            return;
        }

        this.connect(rootPath/*, [this.sensorProperties.portName]*/);
    }

    public getValue(valueIndex: number): number {
        return this.getNumber("value" + valueIndex);
    }

    public getFloatValue(valueIndex: number): number {
        return this.getNumber("value" + valueIndex) / Math.pow(10, this.getNumber("dp"));
    }

    //PROPERTIES
    //~autogen js_generic-get-set classes.sensor>currentClass
    get decimals(): number {
        return this.getNumber("decimals");
    }

    get mode(): string {
        return this.getString("mode");
    }
    set mode(value: string) {
        this.setString("mode", value);
    }
    
    get modes(): string[] {
        return this.getString("modes").split(' ');
    }

    set command(value: string) {
        this.setString("command", value);
    }
    
    get commands(): string[] {
        return this.getString("commands").split(' ');
    }

    get numValues(): number {
        return this.getNumber("num_values");
    }

    get portName(): string {
        return this.getString("port_name");
    }

    get units(): string {
        return this.getString("units");
    }

    get deviceName(): string {
        return this.getString("device_name");
    }


//~autogen
}

class I2CSensor extends Sensor {
    constructor(port: string, types: string[], i2cAddress: string) {
        super(port, types, i2cAddress);
    }

    //~autogen js_generic-get-set classes.i2cSensor>currentClass
    get fwVersion(): string {
        return this.getString("fw_version");
    }

    get address(): string {
        return this.getString("address");
    }

    get pollMs(): number {
        return this.getNumber("poll_ms");
    }
    set pollMs(value: number) {
        this.setNumber("poll_ms", value);
    }
    

//~autogen
}