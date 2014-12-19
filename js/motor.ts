///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />

//~autogen autogen-header
    // Sections of the following code were auto-generated based on spec v0.9.1-pre, rev 4. 
//~autogen

class MotorBase extends Device {
    protected port: string;
    protected deviceDir = '/sys/class/tacho-motor/'; //Default motor type

    protected _deviceIndex: number = -1;
    get deviceIndex(): number {
        return this._deviceIndex;
    }

    get motorBaseProperties(): any {
        return {
            portName: 'port_name',
            type: 'type'
        };
    }

    constructor(port: string, type?: string) {
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

    constructor(port: string, type: string) {
        this.deviceDir = '/sys/class/tacho-motor/';
    
        super(port, type);
    }

    public reset() {
        this.setNumber("reset", 1);
    }

    //PROPERTIES
    //~autogen js_generic-get-set classes.motor>currentClass
    get dutyCycle(): number {
        return this.getNumber("duty_cycle");
    }

    get dutyCycleSp(): number {
        return this.getNumber("duty_cycle_sp");
    }
    set dutyCycleSp(value: number) {
        this.setNumber("duty_cycle_sp", value);
    }
    
    get encoderMode(): string {
        return this.getString("encoder_mode");
    }
    set encoderMode(value: string) {
        this.setString("encoder_mode", value);
    }
    
    get encoderModes(): string[] {
        return this.getString("encoder_modes").split(' ');
    }

    get emergencyStop(): string {
        return this.getString("estop");
    }
    set emergencyStop(value: string) {
        this.setString("estop", value);
    }
    
    get debugLog(): string {
        return this.getString("log");
    }

    get polarityMode(): string {
        return this.getString("polarity_mode");
    }
    set polarityMode(value: string) {
        this.setString("polarity_mode", value);
    }
    
    get polarityModes(): string[] {
        return this.getString("polarity_modes").split(' ');
    }

    get portName(): string {
        return this.getString("port_name");
    }

    get position(): number {
        return this.getNumber("position");
    }
    set position(value: number) {
        this.setNumber("position", value);
    }
    
    get positionMode(): string {
        return this.getString("position_mode");
    }
    set positionMode(value: string) {
        this.setString("position_mode", value);
    }
    
    get positionModes(): string[] {
        return this.getString("position_modes").split(' ');
    }

    get positionSp(): number {
        return this.getNumber("position_sp");
    }
    set positionSp(value: number) {
        this.setNumber("position_sp", value);
    }
    
    get pulsesPerSecond(): number {
        return this.getNumber("pulses_per_second");
    }

    get pulsesPerSecondSp(): number {
        return this.getNumber("pulses_per_second_sp");
    }
    set pulsesPerSecondSp(value: number) {
        this.setNumber("pulses_per_second_sp", value);
    }
    
    get rampDownSp(): number {
        return this.getNumber("ramp_down_sp");
    }
    set rampDownSp(value: number) {
        this.setNumber("ramp_down_sp", value);
    }
    
    get rampUpSp(): number {
        return this.getNumber("ramp_up_sp");
    }
    set rampUpSp(value: number) {
        this.setNumber("ramp_up_sp", value);
    }
    
    get regulationMode(): string {
        return this.getString("regulation_mode");
    }
    set regulationMode(value: string) {
        this.setString("regulation_mode", value);
    }
    
    get regulationModes(): string[] {
        return this.getString("regulation_modes").split(' ');
    }

    get run(): number {
        return this.getNumber("run");
    }
    set run(value: number) {
        this.setNumber("run", value);
    }
    
    get runMode(): string {
        return this.getString("run_mode");
    }
    set runMode(value: string) {
        this.setString("run_mode", value);
    }
    
    get runModes(): string[] {
        return this.getString("run_modes").split(' ');
    }

    get speedRegulationP(): number {
        return this.getNumber("speed_regulation_P");
    }
    set speedRegulationP(value: number) {
        this.setNumber("speed_regulation_P", value);
    }
    
    get speedRegulationI(): number {
        return this.getNumber("speed_regulation_I");
    }
    set speedRegulationI(value: number) {
        this.setNumber("speed_regulation_I", value);
    }
    
    get speedRegulationD(): number {
        return this.getNumber("speed_regulation_D");
    }
    set speedRegulationD(value: number) {
        this.setNumber("speed_regulation_D", value);
    }
    
    get speedRegulationK(): number {
        return this.getNumber("speed_regulation_K");
    }
    set speedRegulationK(value: number) {
        this.setNumber("speed_regulation_K", value);
    }
    
    get state(): string {
        return this.getString("state");
    }

    get stopMode(): string {
        return this.getString("stop_mode");
    }
    set stopMode(value: string) {
        this.setString("stop_mode", value);
    }
    
    get stopModes(): string[] {
        return this.getString("stop_modes").split(' ');
    }

    get timeSp(): number {
        return this.getNumber("time_sp");
    }
    set timeSp(value: number) {
        this.setNumber("time_sp", value);
    }
    
    get type(): string {
        return this.getString("type");
    }


//~autogen
    
}

//DC Motor
class DCMotor extends MotorBase {

    constructor(port: string) {
        this.deviceDir = '/sys/class/dc-motor/';
    
        super(port);
    }

    //PROPERTIES

    //~autogen js_generic-get-set classes.dcMotor>currentClass

    set command(value: string) {
        this.setString("command", value);
    }
    
    get commands(): string[] {
        return this.getString("commands").split(' ');
    }

    get dutyCycle(): number {
        return this.getNumber("duty_cycle");
    }
    set dutyCycle(value: number) {
        this.setNumber("duty_cycle", value);
    }
    
    get typeName(): string {
        return this.getString("name");
    }

    get portName(): string {
        return this.getString("port_name");
    }

    get rampDownMs(): number {
        return this.getNumber("ramp_down_ms");
    }
    set rampDownMs(value: number) {
        this.setNumber("ramp_down_ms", value);
    }
    
    get rampUpMs(): number {
        return this.getNumber("ramp_up_ms");
    }
    set rampUpMs(value: number) {
        this.setNumber("ramp_up_ms", value);
    }
    
    get polarity(): string {
        return this.getString("polarity");
    }
    set polarity(value: string) {
        this.setString("polarity", value);
    }
    

//~autogen
    }
    
//Servo Motor
class ServoMotor extends MotorBase {

    constructor(port: string) {
        this.deviceDir = '/sys/class/servo-motor/';
    
        super(port);
    }
    
    //PROPERTIES

    //~autogen js_generic-get-set classes.servoMotor>currentClass
    get command(): string {
        return this.getString("command");
    }
    set command(value: string) {
        this.setString("command", value);
    }
    
    get typeName(): string {
        return this.getString("name");
    }

    get portName(): string {
        return this.getString("port_name");
    }

    get maxPulseMs(): number {
        return this.getNumber("max_pulse_ms");
    }
    set maxPulseMs(value: number) {
        this.setNumber("max_pulse_ms", value);
    }
    
    get midPulseMs(): number {
        return this.getNumber("mid_pulse_ms");
    }
    set midPulseMs(value: number) {
        this.setNumber("mid_pulse_ms", value);
    }
    
    get minPulseMs(): number {
        return this.getNumber("min_pulse_ms");
    }
    set minPulseMs(value: number) {
        this.setNumber("min_pulse_ms", value);
    }
    
    get polarity(): string {
        return this.getString("polarity");
    }
    set polarity(value: string) {
        this.setString("polarity", value);
    }
    
    get position(): number {
        return this.getNumber("position");
    }
    set position(value: number) {
        this.setNumber("position", value);
    }
    
    get rate(): number {
        return this.getNumber("rate");
    }
    set rate(value: number) {
        this.setNumber("rate", value);
    }
    

//~autogen
}