
namespace ev3dev
{
	public errordomain DeviceError
	{
		NOT_CONNECTED,
		IO_ERROR
	}

	public class Device : GLib.Object
	{
		string DeviceRoot { get; protected set; }
		public bool Connected { get; protected set; }
	
		private string ConnectError = "You must connect to a device before you can read from it.";
		private string ReadError = "There was an error reading from the file.";
		private string WriteError = "There was an error writing to the file.";

		public Device()
		{
		}

		public void Connect(string DeviceRootPath)
		{
			this.DeviceRoot = DeviceRootPath;
			this.Connected = true;
		}

		private string ConstructPropertyPath(string Property)
		{
			return GLib.Path.build_filename(this.DeviceRoot, Property);
		}

		public int ReadInt(string Property) throws DeviceError
		{
			string StrValue = this.ReadString(Property);

			int Result;
			Result = int.parse(StrValue);

			return Result;
		}

		public string ReadString(string Property) throws DeviceError
		{
			if(!this.Connected)
				throw new DeviceError.NOT_CONNECTED(this.ConnectError);

			string Result;
			try
			{
				var File = File.new_for_path(this.ConstructPropertyPath(Property));
				var InputStream = new DataInputStream(File.read());
				Result = InputStream.read_line();
			}
			catch (GLib.Error error)
			{
				throw new DeviceError.IO_ERROR(this.ReadError + ": " + error.message + ": " + this.ConstructPropertyPath(Property));
			}

			return Result;
		}

		/* Note: All write methods have a limit of 255 bytes to increase write speed */

		public void WriteInt(string Property, int Value) throws DeviceError
		{
			this.WriteString(Property, Value.to_string());
		}

		public void WriteString(string Property, string Value) throws DeviceError
		{
			if(!this.Connected)
				throw new DeviceError.NOT_CONNECTED(this.ConnectError);

			try
			{
				var File = File.new_for_path(this.ConstructPropertyPath(Property));
				var OutputStream = new DataOutputStream(new BufferedOutputStream.sized(File.open_readwrite().output_stream, 256));
				OutputStream.put_string(Value);
			}
			catch
			{
				throw new DeviceError.IO_ERROR(this.WriteError);
			}
		}
	}

	public enum Ports
	{
		INPUT_AUTO = 0,
		OUTPUT_AUTO = 0,
	
		INPUT_1 = 1,
		INPUT_2 = 2,
		INPUT_3 = 3,
		INPUT_4 = 4,

		OUTPUT_A = 1,
		OUTPUT_B = 2,
		OUTPUT_C = 3,
		OUTPUT_D = 4
	}

	public class Motor : Device
	{
		private int Port;
		private string MotorDeviceDir = "/sys/class/tacho-motor";
		private int DeviceIndex { get; private set; default = -1; }

		private string[] MotorPorts = {"*", "A", "B", "C", "D"};

		public Motor (int Port)
		{
			this.Port = Port;
			string RootPath = "";

			try
			{
				var Directory = File.new_for_path(this.MotorDeviceDir);
				var Enumerator = Directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);

				FileInfo DeviceFile;
				while((DeviceFile = Enumerator.next_file()) != null)
				{
					if(DeviceFile.get_file_type() == FileType.DIRECTORY)
						continue;

					string DeviceFileName = DeviceFile.get_name();

					RootPath = Path.build_path("/", this.MotorDeviceDir, DeviceFileName);

					var PortNameFile = File.new_for_path(Path.build_path("/", RootPath, "port_name"));
					var InputStream = new DataInputStream(PortNameFile.read());
					string PortName = InputStream.read_line();

					bool SatisfiesCondition = (Port == Ports.OUTPUT_AUTO) || (PortName == ("out" + this.MotorPorts[Port]));

					if(SatisfiesCondition)
					{
						this.DeviceIndex = int.parse(DeviceFileName.substring(11));
						break;
					}
				}

				if(this.DeviceIndex == -1)
				{
					this.Connected = false;
					return;
				}
			}
			catch
			{
				this.Connected = false;
				return;
			}

			this.Connect(RootPath);
		}

		public void Reset()
		{
			this.WriteInt("reset", 1);
		}

		//PROPERTIES
		public string PortName
		{
			owned get
			{
				return this.ReadString("port_name");
			}
		}

		public int DutyCycle
		{
			get
			{
				return this.ReadInt("duty_cycle");
			}
		}

		public int DutyCycleSP
		{
			get
			{
				return this.ReadInt("duty_cycle_sp");
			}

			set
			{
				this.WriteInt("duty_cycle_sp", value);
			}
		}
		
		public int Position
		{
			get
			{
				return this.ReadInt("position");
			}

			set
			{
				this.WriteInt("position", value);
			}
		}
		
		public string PositionMode
		{
			owned get
			{
				return this.ReadString("position_mode");
			}
			
			set
			{
				this.WriteString("position_mode", value);
			}
		}
		
		public int PositionSP
		{
			get
			{
				return this.ReadInt("position_sp");
			}

			set
			{
				this.WriteInt("position_sp", value);
			}
		}
		
		public int PulsesPerSecond
		{
			get
			{
				return this.ReadInt("pulses_per_second");
			}
		}
		
		public int PulsesPerSecondSP
		{
			get
			{
				return this.ReadInt("pulses_per_second_sp");
			}
			
			set
			{
				this.WriteInt("pulses_per_second_sp", value);
			}
		}
		
		public int RampDownSP
		{
			get
			{
				return this.ReadInt("ramp_down_sp");
			}

			set
			{
				this.WriteInt("ramp_down_sp", value);
			}
		}
		
		public int RampUpSP
		{
			get
			{
				return this.ReadInt("ramp_up_sp");
			}

			set
			{
				this.WriteInt("ramp_up_sp", value);
			}
		}
		
		public string RegulationMode
		{
			owned get
			{
				return this.ReadString("regulation_mode");
			}
			
			set
			{
				this.WriteString("regulation_mode", value);
			}
		}
		
		public int Run
		{
			get
			{
				return this.ReadInt("run");
			}

			set
			{
				this.WriteInt("run", value);
			}
		}

		public string RunMode
		{
			owned get
			{
				return this.ReadString("run_mode");
			}
			
			set
			{
				this.WriteString("run_mode", value);
			}
		}
		
		public int SpeedRegulationP
		{
			get
			{
				return this.ReadInt("speed_regulation_P");
			}

			set
			{
				this.WriteInt("speed_regulation_P", value);
			}
		}
		
		public int SpeedRegulationI
		{
			get
			{
				return this.ReadInt("speed_regulation_I");
			}

			set
			{
				this.WriteInt("speed_regulation_I", value);
			}
		}
		
		public int SpeedRegulationD
		{
			get
			{
				return this.ReadInt("speed_regulation_D");
			}

			set
			{
				this.WriteInt("speed_regulation_D", value);
			}
		}
		
		public int SpeedRegulationK
		{
			get
			{
				return this.ReadInt("speed_regulation_K");
			}

			set
			{
				this.WriteInt("speed_regulation_K", value);
			}
		}
		
		public string State
		{
			owned get
			{
				return this.ReadString("state");
			}
		}
		
		public string StopMode
		{
			owned get
			{
				return this.ReadString("stop_mode");
			}
			
			set
			{
				this.WriteString("stop_mode", value);
			}
		}
		
		public string[] StopModes
		{
			owned get
			{
				return this.ReadString("stop_modes").split(" ");
			}
		}
		
		public int TimeSP
		{
			get
			{
				return this.ReadInt("time_sp");
			}

			set
			{
				this.WriteInt("time_sp", value);
			}
		}
		
		public string Type
		{
			owned get
			{
				return this.ReadString("type");
			}
		}
	}
}