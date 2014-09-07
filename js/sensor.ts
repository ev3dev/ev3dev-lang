///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />

class Sensor extends Device {
    private port: number;
    private sensorDeviceDir = '/sys/class/msensor/';

    private sensorTypes : number[] = [];

    private _deviceIndex: number = -1;
    get deviceIndex(): number {
        return this._deviceIndex;
    }

    get sensorProperties(): any {
        return {
            portName: 'port_name',
            numValues: 'num_values',
            typeId: 'type_id',
            mode: 'mode',
            modes: 'modes',
            value: 'value',
            dp: 'dp'
        };
    }

    get sensorPorts(): any {
        return {
            0: '*',
            1: '1',
            2: '2',
            3: '3',
            4: '4'
        };
    }

    constructor(port: number, types: number[]) {
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

                var typeId = parseInt(fs.readFileSync(
                        path.join(rootPath, this.sensorProperties.typeId)
                    ).toString().trim());

                var satisfiesCondition = (
                        (port == ports.INPUT_AUTO)
                        || (portName === ('in' + this.sensorPorts[port]))
                    ) && (
                        (types == undefined || types == [])
                        || types.indexOf(typeId) != -1
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

    get typeId(): number {
        return this.getNumber(this.sensorProperties.typeId);
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