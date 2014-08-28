///<reference path="node.d.ts" />
///<reference path="include.ts" />

class XError {
    public message: string;

    constructor(...tsargs) {
        Error.apply(this, arguments);
        return new Error();
    }
}

XError['prototype'] = new Error();

class TraceError {
    public innerError: any;
    public message: string;

    constructor(message?: string, innerError?: any) {
        this.message = message;
        this.innerError = innerError;
    }

    public toString() {
        var str = this.message.trim() + '\r\nInner error:\r\n';

        var innerLines = this.innerError.toString().split('\r\n');
        for (var i in innerLines) {
            innerLines[i] = '  ' + innerLines[i];
        }
        return str + innerLines.join('\r\n');
    }
}

class Device {
    public deviceRoot: string;
    public connected: boolean = false;
    //private preloadedValues: any;

    public connect(deviceRootPath: string/*, preloadProperties: string[]*/) {
        this.deviceRoot = deviceRootPath;

        ////Preload specified properties, so that properties that don't change are fast to access
        //for (var i in preloadProperties) {
        //    var propertyName = preloadProperties[i];
        //    try {
        //        this.preloadedValues[propertyName] = this.readProperty(propertyName);
        //    }
        //    catch (e) {
        //        this.connected = false;
        //        return;
        //    }
        //}

        this.connected = true;
    }

    private constructPropertyPath(property: string) {
        return path.join(this.deviceRoot, property);
    }


    public readNumber(property: string): number {
        var value = this.readProperty(property);

        if (typeof value !== 'number')
            return NaN;

        return value;
    }

    public getNumber(property: string): number {
        //if (typeof this.preloadedValues[property] !== 'undefined')
        //    return this.preloadedValues[property];
        //else
            return this.readNumber(property);
    }


    public readString(property: string): string {
        var value = this.readProperty(property);
        return String(value);
    }

    public getString(property: string): string {
        //if (typeof this.preloadedValues[property] !== 'undefined')
        //    return this.preloadedValues[property];
        //else
            return this.readString(property);
    }


    public readProperty(property: string): any {
        if (!this.connected)
            throw new Error('You must be connected to a device before you can read from it.');

        var rawValue: string;
        var propertyPath = this.constructPropertyPath(property);

        try {
            rawValue = fs.readFileSync(propertyPath).toString();
        }
        catch (e) {
            this.connected = false;
            throw new TraceError('There was an error while reading from the property file "' + propertyPath + '".', e);
        }

        rawValue = rawValue.trim();
        var numValue = Number(rawValue);

        if (isNaN(numValue))
            return rawValue;
        else
            return numValue;
    }

    public getProperty(property: string): any {
        //if (typeof this.preloadedValues[property] !== 'undefined')
        //    return this.preloadedValues[property];
        //else
            return this.readProperty(property);
    }

    public setProperty(property: string, value: any): any {
        if (!this.connected)
            throw new Error('You must be connected to a device before you can write to it.');

        var propertyPath = this.constructPropertyPath(property);

        try {
            fs.writeFileSync(propertyPath, value.toString());
        }
        catch (e) {
            this.connected = false;
            throw new TraceError('There was an error while writing to the property file "' + propertyPath + '".', e);
        }
    }

    public setNumber(property: string, value: number) {
        this.setProperty(property, value);
    }

    public setString(property: string, value: string) {
        this.setProperty(property, value);
    }
}