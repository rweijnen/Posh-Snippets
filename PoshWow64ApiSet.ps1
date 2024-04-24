$source = @"
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.ComponentModel;

public static class WOWTester
{
    public const ushort IMAGE_FILE_MACHINE_UNKNOWN = 0;
    public const ushort IMAGE_FILE_MACHINE_TARGET_HOST = 0x0001; // Useful for indicating we want to interact with the host and not a WoW guest.
    public const ushort IMAGE_FILE_MACHINE_I386 = 0x014c; // Intel 386.
    public const ushort IMAGE_FILE_MACHINE_R3000 = 0x0162; // MIPS little-endian, = 0x160 big-endian
    public const ushort IMAGE_FILE_MACHINE_R4000 = 0x0166; // MIPS little-endian
    public const ushort IMAGE_FILE_MACHINE_R10000 = 0x0168; // MIPS little-endian
    public const ushort IMAGE_FILE_MACHINE_WCEMIPSV2 = 0x0169; // MIPS little-endian WCE v2
    public const ushort IMAGE_FILE_MACHINE_ALPHA = 0x0184; // Alpha_AXP
    public const ushort IMAGE_FILE_MACHINE_SH3 = 0x01a2; // SH3 little-endian
    public const ushort IMAGE_FILE_MACHINE_SH3DSP = 0x01a3;
    public const ushort IMAGE_FILE_MACHINE_SH3E = 0x01a4; // SH3E little-endian
    public const ushort IMAGE_FILE_MACHINE_SH4 = 0x01a6; // SH4 little-endian
    public const ushort IMAGE_FILE_MACHINE_SH5 = 0x01a8; // SH5
    public const ushort IMAGE_FILE_MACHINE_ARM = 0x01c0; // ARM Little-Endian
    public const ushort IMAGE_FILE_MACHINE_THUMB = 0x01c2; // ARM Thumb/Thumb-2 Little-Endian
    public const ushort IMAGE_FILE_MACHINE_ARMNT = 0x01c4; // ARM Thumb-2 Little-Endian, this is the Machine Type observed on Windows RT (Windows 8/8.1 for ARM)
    public const ushort IMAGE_FILE_MACHINE_AM33 = 0x01d3;
    public const ushort IMAGE_FILE_MACHINE_POWERPC = 0x01F0; // IBM PowerPC Little-Endian
    public const ushort IMAGE_FILE_MACHINE_POWERPCFP = 0x01f1;
    public const ushort IMAGE_FILE_MACHINE_IA64 = 0x0200; // Intel 64
    public const ushort IMAGE_FILE_MACHINE_MIPS16 = 0x0266; // MIPS
    public const ushort IMAGE_FILE_MACHINE_ALPHA64 = 0x0284; // ALPHA64
    public const ushort IMAGE_FILE_MACHINE_MIPSFPU = 0x0366; // MIPS
    public const ushort IMAGE_FILE_MACHINE_MIPSFPU16 = 0x0466; // MIPS
    public const ushort IMAGE_FILE_MACHINE_AXP64 = IMAGE_FILE_MACHINE_ALPHA64;
    public const ushort IMAGE_FILE_MACHINE_TRICORE = 0x0520; // Infineon
    public const ushort IMAGE_FILE_MACHINE_CEF = 0x0CEF;
    public const ushort IMAGE_FILE_MACHINE_EBC = 0x0EBC; // EFI Byte Code
    public const ushort IMAGE_FILE_MACHINE_AMD64 = 0x8664; // AMD64 (K8)
    public const ushort IMAGE_FILE_MACHINE_M32R = 0x9041; // M32R little-endian
    public const ushort IMAGE_FILE_MACHINE_ARM64 = 0xAA64; // ARM64 Little-Endian
    public const ushort IMAGE_FILE_MACHINE_CEE = 0xC0EE;

    public const UInt32 S_OK = 0;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern UInt32 IsWow64GuestMachineSupported(ushort WowGuestMachine, out bool MachineIsSupported);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool IsWow64Process2(IntPtr hProcess, out ushort pProcessMachine, out ushort pNativeMachine);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr GetCurrentProcess();

    public static string MachineTypeToStr(ushort MachineType)
    {
        switch (MachineType)
        {
            case IMAGE_FILE_MACHINE_UNKNOWN:
                return "IMAGE_FILE_MACHINE_UNKNOWN";
            case IMAGE_FILE_MACHINE_TARGET_HOST:
                return "IMAGE_FILE_MACHINE_TARGET_HOST";
            case IMAGE_FILE_MACHINE_I386:
                return "IMAGE_FILE_MACHINE_I386";
            case IMAGE_FILE_MACHINE_R3000:
                return "IMAGE_FILE_MACHINE_R3000";
            case IMAGE_FILE_MACHINE_R4000:
                return "IMAGE_FILE_MACHINE_R4000";
            case IMAGE_FILE_MACHINE_R10000:
                return "IMAGE_FILE_MACHINE_R10000";
            case IMAGE_FILE_MACHINE_WCEMIPSV2:
                return "IMAGE_FILE_MACHINE_WCEMIPSV2";
            case IMAGE_FILE_MACHINE_ALPHA:
                return "IMAGE_FILE_MACHINE_ALPHA";
            case IMAGE_FILE_MACHINE_SH3:
                return "IMAGE_FILE_MACHINE_SH3";
            case IMAGE_FILE_MACHINE_SH3DSP:
                return "IMAGE_FILE_MACHINE_SH3DSP";
            case IMAGE_FILE_MACHINE_SH3E:
                return "IMAGE_FILE_MACHINE_SH3E";
            case IMAGE_FILE_MACHINE_SH4:
                return "IMAGE_FILE_MACHINE_SH4";
            case IMAGE_FILE_MACHINE_SH5:
                return "IMAGE_FILE_MACHINE_SH5";
            case IMAGE_FILE_MACHINE_ARM:
                return "IMAGE_FILE_MACHINE_ARM";
            case IMAGE_FILE_MACHINE_THUMB:
                return "IMAGE_FILE_MACHINE_THUMB";
            case IMAGE_FILE_MACHINE_ARMNT:
                return "IMAGE_FILE_MACHINE_ARMNT";
            case IMAGE_FILE_MACHINE_AM33:
                return "IMAGE_FILE_MACHINE_AM33";
            case IMAGE_FILE_MACHINE_POWERPC:
                return "IMAGE_FILE_MACHINE_POWERPC";
            case IMAGE_FILE_MACHINE_POWERPCFP:
                return "IMAGE_FILE_MACHINE_POWERPCFP";
            case IMAGE_FILE_MACHINE_IA64:
                return "IMAGE_FILE_MACHINE_IA64";
            case IMAGE_FILE_MACHINE_MIPS16:
                return "IMAGE_FILE_MACHINE_MIPS16";
            case IMAGE_FILE_MACHINE_ALPHA64:
                return "IMAGE_FILE_MACHINE_ALPHA64";
            case IMAGE_FILE_MACHINE_MIPSFPU:
                return "IMAGE_FILE_MACHINE_MIPSFPU";
            case IMAGE_FILE_MACHINE_MIPSFPU16:
                return "IMAGE_FILE_MACHINE_MIPSFPU16";
            case IMAGE_FILE_MACHINE_TRICORE:
                return "IMAGE_FILE_MACHINE_TRICORE";
            case IMAGE_FILE_MACHINE_CEF:
                return "IMAGE_FILE_MACHINE_CEF";
            case IMAGE_FILE_MACHINE_EBC:
                return "IMAGE_FILE_MACHINE_EBC";
            case IMAGE_FILE_MACHINE_AMD64:
                return "IMAGE_FILE_MACHINE_AMD64";
            case IMAGE_FILE_MACHINE_M32R:
                return "IMAGE_FILE_MACHINE_M32R";
            case IMAGE_FILE_MACHINE_ARM64:
                return "IMAGE_FILE_MACHINE_ARM64";
            case IMAGE_FILE_MACHINE_CEE:
                return "IMAGE_FILE_MACHINE_CEE";
            default:
                return "Unknown Machine Type";
        }
    }

    public static string MachineTypeToProcessorArchitectureEnvironmentVariableStr(ushort MachineType)
    {
        switch (MachineType)
        {
            case IMAGE_FILE_MACHINE_I386:
                return "x86";
            case IMAGE_FILE_MACHINE_ARMNT:
                return "ARM";
            case IMAGE_FILE_MACHINE_IA64:
                return "IA64";
            case IMAGE_FILE_MACHINE_AMD64:
                return "AMD64";
            case IMAGE_FILE_MACHINE_ARM64:
                return "ARM64";
            default:
                return "";
        }
    }

    public static ushort ProcessorArchitectureEnvironmentVariableStrToMachineType(string ProcessorArchitectureEnvironmentVariable)
    {
        switch (ProcessorArchitectureEnvironmentVariable)
        {
            case "x86":
                return IMAGE_FILE_MACHINE_I386;
            case "ARM":
                return IMAGE_FILE_MACHINE_ARMNT;
            case "IA64":
                return IMAGE_FILE_MACHINE_IA64;
            case "AMD64":
                return IMAGE_FILE_MACHINE_AMD64;
            case "ARM64":
                return IMAGE_FILE_MACHINE_ARM64;
            default:
                return IMAGE_FILE_MACHINE_UNKNOWN;
        }
    }
}
"@

Add-Type $source

function Test-OperatingSystemCanRunProcessorArchitecture {
    # Example usage:
    # Test-OperatingSystemCanRunProcessorArchitecture 'ARM64'
    #
    # Supported processor architectures are:
    #  - 'x86' (i.e., Intel IA-32 or compatible)
    #  - 'AMD64' (including Intel x86-x64)
    #  - 'IA64' (i.e., Itanium)
    #  - 'ARM' (i.e., 32-bit ARM)
    #  - 'ARM64' (i.e., 64-bit ARM)

    # Could convert this to params() if desired
    $strProcessorArchitectureToTest = $args[0]

    [bool]$boolMachineIsSupported = $false

    $uint16MachineTypeToTest = [WOWTester]::ProcessorArchitectureEnvironmentVariableStrToMachineType($strProcessorArchitectureToTest)
    $uint32ResultCode = [WOWTester]::IsWow64GuestMachineSupported($uint16MachineTypeToTest, [ref]$boolMachineIsSupported)
    if ($uint32ResultCode -eq [WOWTester]::S_OK) {
        if ($boolMachineIsSupported) {
            # Return $true
            $true
        }
    }

    if ($boolMachineIsSupported -ne $true) {
        # The processor architecture is not supported under WOW.
        # Check native
        [UInt16]$uint16WOWProcessMachineType = 0
        [UInt16]$uint16OperatingSystemMachineType = 0
        $boolResult = [WOWTester]::IsWow64Process2([WOWTester]::GetCurrentProcess(), [ref]$uint16WOWProcessMachineType, [ref]$uint16OperatingSystemMachineType);
        if ($boolResult) {
            # Get the OS processor architecture. Note that there are more PowerShell-y ways to
            # do this, namely reading the following registry value:
            # Registry key: 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            # Registry string value: 'PROCESSOR_ARCHITECTURE'
            $strOperatingSystemProcessorArchitecture = [WOWTester]::MachineTypeToProcessorArchitectureEnvironmentVariableStr($uint16OperatingSystemMachineType)
            if ($strProcessorArchitectureToTest -eq $strOperatingSystemProcessorArchitecture) {
                $boolMachineIsSupported = $true
                # Return $true
                $true
            }
        }
    }

    if ($boolMachineIsSupported -ne $true) {
        # Still here? Return $false
        $false
    }
}
