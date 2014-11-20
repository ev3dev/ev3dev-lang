///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />

class MotorBase extends Device {
    private port: string;
    private deviceDir = '/sys/class/tacho-motor/'; //Default motor type

    private _deviceIndex: number = -1;
    get deviceIndex(): number {
        return this._deviceIndex;
    }

    get portName(): string {
        return this.port;
    }
    
    get motorBaseProperties(): any {
        return {
            portName: 'port_name',
            type: 'type'
        };
    }

    constructor(port: string, type: string) {
        super();

        this.port = port;
        var rootPath: string;

        try {
            var availableDevices = fs.readdirSync(this.deviceDir);
            for (var i in availableDevices) {
                var file = availableDevices[i];

                rootPath = path.join(this.deviceDir, file);
                var portName = fs.readFileSync(
                    path.join(rootPath, this.motorBaseProperties.portName)
                    ).toString().trim();

                var motorType = fs.readFileSync(
                    path.join(rootPath, this.motorBaseProperties.type)
                    ).toString().trim();

                var satisfiesCondition = (
                    (port == ports.OUTPUT_AUTO)
                    || (port == undefined)
                    || (portName === port)
                ) && (
                    (type == undefined || type == '')
                    || motorType == type
                );

                if (satisfiesCondition) {
                    this._deviceIndex = Number(file.substring('motor'.length));
                    break;
                }
            }

            if (this.deviceIndex == -1) {
                console.log('no device found');
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
}

//Tacho motor
class Motor extends MotorBase {

    get motorProperties(): any {
        return {
            portName: 'port_name',
            dutyCycle: 'duty_cycle',
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

    constructor(port: string, type: string) {
        this.deviceDir = '/sys/class/tacho-motor/';
    
        super(port, type);
    }

    public reset() {
        this.setNumber(this.motorProperties.reset, 1);
    }

    //PROPERTIES

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

//DC Motor
class DCMotor extends MotorBase {

    get motorProperties(): any {
        return {
            command: 'command',
            commands: 'commands',
            name: 'name',
            dutyCycle: 'duty_cycle',
            rampUpMs: 'ramp_up_ms',
            rampDownMs: 'ramp_down_ms',
            polarity: 'polarity'
        };
    }

    constructor(port: string) {
        this.deviceDir = '/sys/class/dc-motor/';
    
        super(port);
    }

    //PROPERTIES
    get dutyCycle(): number {
        return this.getNumber(this.motorProperties.dutyCycle);
    }

    set dutyCycle(value: number) {
        this.setNumber(this.motorProperties.dutyCycle, value);
    }


    get command(): string {
        return this.getString(this.motorProperties.command);
    }

    set command(value: string) {
        this.setString(this.motorProperties.command, value);
    }


    get commands(): string[] {
        return this.getString(this.motorProperties.commands).split(' ');
    }
    
    
    get typeName(): string {
        return this.getString(this.motorProperties.name);
    }
    
    get rampDownMs(): number {
        return this.getNumber(this.motorProperties.rampDownMs);
    }

    set rampDownMs(value: number) {
        this.setNumber(this.motorProperties.rampDownMs, value);
    }


    get rampUpMs(): number {
        return this.getNumber(this.motorProperties.rampUpMs);
    }

    set rampUpMs(value: number) {
        this.setNumber(this.motorProperties.rampUpMs, value);
    }


    get polarity(): string {
        return this.getString(this.motorProperties.polarity);
    }

    set polarity(value: string) {
        this.setString(this.motorProperties.polarity, value);
    }
}