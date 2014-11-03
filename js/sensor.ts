///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />

class Sensor extends Device {
    private port: string;
    private sensorDeviceDir = '/sys/class/msensor/';

    private sensorTypes : string[] = [];

    private _deviceIndex: number = -1;
    get deviceIndex(): number {
        return this._deviceIndex;
    }

    get sensorProperties(): any {
        return {
            portName: 'port_name',
            numValues: 'num_values',
            name: 'name',
            address: 'address',
            mode: 'mode',
            modes: 'modes',
            value: 'value',
            dp: 'dp',
            pollMS: 'poll_ms',
            fwVersion: 'fw_version'
        };
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
                        path.join(rootPath, this.sensorProperties.portName)
                    ).toString().trim();

                var typeName = fs.readFileSync(
                        path.join(rootPath, this.sensorProperties.name)
                    ).toString().trim();

                var i2cDeviceAddress = fs.readFileSync(
                        path.join(rootPath, this.sensorProperties.address)
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
        return this.getNumber(this.sensorProperties.value + valueIndex);
    }

    public getFloatValue(valueIndex: number): number {
        return this.getNumber(this.sensorProperties.value + valueIndex) / Math.pow(10, this.getNumber(this.sensorProperties.dp));
    }

    //PROPERTIES
    get portName(): string {
        return this.getProperty(this.sensorProperties.portName);
    }

    get numValues(): number {
        return this.getNumber(this.sensorProperties.numValues);
    }

    get typeName(): string {
        return this.getString(this.sensorProperties.name);
    }

    get mode(): string {
        return this.getProperty(this.sensorProperties.mode);
    }

    set mode(value: string) {
        this.setProperty(this.sensorProperties.mode, value);
    }

    get modes(): string[] {
        return this.getProperty(this.sensorProperties.modes).split(' ');
    }
}

class I2CSensor extends Sensor {
    constructor(port: string, types: string[], i2cAddress: string) {
        super(port, types, i2cAddress);
    }

    get pollMS(): number {
        return this.getProperty(this.sensorProperties.pollMS);
    }

    set pollMS(value: number) {
        this.setProperty(this.sensorProperties.pollMS, value);
    }

    get fwVersion(): string {
        return this.getProperty(this.sensorProperties.fwVersion);
    }
}