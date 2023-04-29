import serial
ComPort = 'COM6';
#ComPort = 'COM10';
BaudRate = 256000;
ProgramDataFileName = "custom_printf.hex"
ProgramSequence = "TEKNOFEST"
FileFormat = 1

if FileFormat == 1:
    ProgramData = open(ProgramDataFileName, 'r').read()
    lines = ProgramData.split('\n')
    ser = serial.Serial(ComPort, BaudRate)
    ser.timeout = 1
    ser.write(ProgramSequence.encode('utf-8'))
    print(ProgramSequence.encode('utf-8'))
    HexStr = hex(len(lines))
    print("Number of instruction is " + str(len(lines)) + " = " + HexStr)
    print(HexStr)
    print(int(HexStr, 16))
    HexStr = int(HexStr, 16).to_bytes(4, 'big')
    ser.write(HexStr)
    i = 0
    for line in lines:
        if len(line) < 8:
            ReadData = ReadData
            ser.write(int("0x00000013", 16).to_bytes(4, 'big'))
        else:
            i = i + 1
            lineModified = "0x" + line.strip()
            #print(str(i) + ". " + str(int(lineModified, 16)))
            ReadData = int(lineModified, 16).to_bytes(4, 'big')
            ser.write(ReadData)

print("Done Programming.")
