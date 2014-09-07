///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />

class Motor extends Device {
    private port: number;
    private motorDeviceDir = '/sys/class/tacho-motor/';

    private _deviceIndex: number = -1;
    get deviceIndex(): number {
        return this._deviceIndex;
    }

    get motorProperties(): any {
        return {
            portName: 'port_name',
            dutyCycle: 'duty_cyle',
            dutyCycleSp: 'duty_cycle_sp',
            position: 'position',
            positionMode: 'position_mode',
            positionSp: 'position_sp',
            pulsesPerSecond: 'pulses_per_second',
            pulsesPerSecondSp: 'pulses_per_second_sp',
            rampDownSp: 'ramp_down_sp',
            rampUpSp: 'ramp_up_sp',
            regulationMode: 'regulation_mode',
            reset: 'reset',
            run: 'run',
            runMode: 'run_mode',
            speedRegulationP: 'speed_regulation_P',
            speedRegulationI: 'speed_regulation_I',
            speedRegulationD: 'speed_regulation_D',
            speedRegulationK: 'speed_regulation_K',
            state: 'state',
            stopMode: 'stop_mode',
            stopModes: 'stop_modes',
            timeSp: 'time_sp',
            type: 'type'
        };
    }

    get motorPorts(): any {
        return {
            0: '*',
            1: 'A',
            2: 'B',
            3: 'C',
            4: 'D'
        };
    }

    constructor(port: number, type: string) {
        super();

        this.port = port;
        var rootPath: string;

        try {
            var availableDevices = fs.readdirSync(this.motorDeviceDir);
            for (var i in availableDevices) {
                var file = availableDevices[i];

                rootPath = path.join(this.motorDeviceDir, file);
                var portName = fs.readFileSync(
                    path.join(rootPath, this.motorProperties.portName)
                    ).toString().trim();

                var motorType = fs.readFileSync(
                    path.join(rootPath, this.motorProperties.type)
                    ).toString().trim();

                var satisfiesCondition = (
                    (port == ports.OUTPUT_AUTO)
                    || (portName === ('out' + this.motorPorts[port]))
                ) && (
                    (type == undefined || type == '')
                    || motorType == type
                );

                if (satisfiesCondition) {
                    this._deviceIndex = Number(file.substring('tacho-motor'.length));
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

        this.connect(rootPath/*, [this.motorProperties.portName]*/);
    }

    public reset() {
        this.setNumber(this.motorProperties.reset, 1);
    }

    //PROPERTIES
    get portName(): string {
        return this.getProperty(this.motorProperties.portName);
    }


    get dutyCycle(): number {
        return this.getNumber(this.motorProperties.dutyCycle);
    }


    get dutyCycleSp(): number {
        return this.getNumber(this.motorProperties.dutyCycleSp);
    }

    set dutyCycleSp(value: number) {
        this.setNumber(this.motorProperties.dutyCycleSp, value);
    }


    get position(): number {
        return this.getNumber(this.motorProperties.position);
    }

    set position(value: number) {
        this.setNumber(this.motorProperties.position, value);
    }


    get positionMode(): string {
        return this.getString(this.motorProperties.positionMode);
    }

    set positionMode(value: string) {
        this.setString(this.motorProperties.positionMode, value);
    }


    get positionSp(): number {
        return this.getNumber(this.motorProperties.positionSp);
    }

    set positionSp(value: number) {
        this.setNumber(this.motorProperties.positionSp, value);
    }


    get pulsesPerSecond(): number {
        return this.getNumber(this.motorProperties.pulsesPerSecond);
    }


    get pulsesPerSecondSp(): number {
        return this.getNumber(this.motorProperties.pulsesPerSecondSp);
    }

    set pulsesPerSecondSp(value: number) {
        this.setNumber(this.motorProperties.pulsesPerSecondSp, value);
    }


    get rampDownSp(): number {
        return this.getNumber(this.motorProperties.rampDownSp);
    }

    set rampDownSp(value: number) {
        this.setNumber(this.motorProperties.rampDownSp, value);
    }


    get rampUpSp(): number {
        return this.getNumber(this.motorProperties.rampUpSp);
    }

    set rampUpSp(value: number) {
        this.setNumber(this.motorProperties.rampUpSp, value);
    }


    get regulationMode(): string {
        return this.getString(this.motorProperties.regulationMode);
    }

    set regulationMode(value: string) {
        this.setString(this.motorProperties.regulationMode, value);
    }


    get run(): number {
        return this.getNumber(this.motorProperties.run);
    }

    set run(value: number) {
        this.setNumber(this.motorProperties.run, value);
    }


    get runMode(): string {
        return this.getString(this.motorProperties.runMode);
    }

    set runMode(value: string) {
        this.setString(this.motorProperties.runMode, value);
    }


    get speedRegulationP(): number {
        return this.getNumber(this.motorProperties.speedRegulationP);
    }

    set speedRegulationP(value: number) {
        this.setNumber(this.motorProperties.speedRegulationP, value);
    }


    get speedRegulationI(): number {
        return this.getNumber(this.motorProperties.speedRegulationI);
    }

    set speedRegulationI(value: number) {
        this.setNumber(this.motorProperties.speedRegulationI, value);
    }


    get speedRegulationD(): number {
        return this.getNumber(this.motorProperties.speedRegulationD);
    }

    set speedRegulationD(value: number) {
        this.setNumber(this.motorProperties.speedRegulationD, value);
    }


    get speedRegulationK(): number {
        return this.getNumber(this.motorProperties.speedRegulationK);
    }

    set speedRegulationK(value: number) {
        this.setNumber(this.motorProperties.speedRegulationK, value);
    }


    get state(): string {
        return this.getString(this.motorProperties.state);
    }


    get stopMode(): string {
        return this.getString(this.motorProperties.stopMode);
    }

    set stopMode(value: string) {
        this.setString(this.motorProperties.stopMode, value);
    }


    get stopModes(): string[] {
        return this.getString(this.motorProperties.stopModes).split(' ');
    }


    get timeSp(): number {
        return this.getNumber(this.motorProperties.timeSp);
    }

    set timeSp(value: number) {
        this.setNumber(this.motorProperties.timeSp, value);
    }


    get type(): string {
        return this.getString(this.motorProperties.type);
    }
}