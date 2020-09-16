$code = @"
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
using Microsoft.Win32;

namespace Win32
{
    public class Api
    {
        internal const String ADVAPI32 = "advapi32.dll";
        internal const string NTDLL = "ntdll.dll";

        // Win32 ACL-related constants:
        internal const int READ_CONTROL = 0x00020000;
        internal const int SYNCHRONIZE = 0x00100000;
        internal const int DELETE = 0x00010000;

        internal const int STANDARD_RIGHTS_READ = READ_CONTROL;
        internal const int STANDARD_RIGHTS_WRITE = READ_CONTROL;

        internal const int KEY_QUERY_VALUE = 0x0001;
        internal const int KEY_SET_VALUE = 0x0002;
        internal const int KEY_CREATE_SUB_KEY = 0x0004;
        internal const int KEY_ENUMERATE_SUB_KEYS = 0x0008;
        internal const int KEY_NOTIFY = 0x0010;
        internal const int KEY_CREATE_LINK = 0x0020;
        internal const int KEY_READ = ((STANDARD_RIGHTS_READ |
                                                           KEY_QUERY_VALUE |
                                                           KEY_ENUMERATE_SUB_KEYS |
                                                           KEY_NOTIFY)
                                                          &
                                                          (~SYNCHRONIZE));

        internal const int KEY_WRITE = ((STANDARD_RIGHTS_WRITE |
                                                           KEY_SET_VALUE |
                                                           KEY_CREATE_SUB_KEY)
                                                          &
                                                          (~SYNCHRONIZE));

        internal const int REG_OPTION_OPEN_LINK = 0x0008; // Open symbolic link
        internal const int REG_OPTION_CREATE_LINK = 0x0002;     // They key is a symbolic link
        internal const int REG_LINK = 6;     // Symbolic Link (unicode)

        internal const int ERROR_SUCCESS = 0x0;
        internal const int S_OK = 0x0;

        [DllImport(ADVAPI32, CharSet = CharSet.Auto, BestFitMapping = false)]
        internal static extern int RegCreateKeyEx(SafeRegistryHandle hKey, String lpSubKey,
            int Reserved, String lpClass, int dwOptions,
            int samDesired, IntPtr lpSecurityAttributes,
            out SafeRegistryHandle hkResult, out int lpdwDisposition);

        [DllImport(ADVAPI32, CharSet = CharSet.Auto, BestFitMapping = false)]
        internal static extern int RegSetValueEx(SafeRegistryHandle hKey, String lpValueName,
                    int Reserved, int dwType, byte[] lpData, int cbData);

        [DllImport(ADVAPI32, CharSet = CharSet.Auto, BestFitMapping = false)]
        internal static extern int RegOpenKeyEx(SafeRegistryHandle hKey, String lpSubKey,
                    int ulOptions, int samDesired, out SafeRegistryHandle hkResult);

        [DllImport(NTDLL, CharSet = CharSet.None, BestFitMapping = false)]
        internal static extern int NtDeleteKey(SafeRegistryHandle hKey);
        public static bool CreateRegSymLink(string Link, string Target)
        {
            bool bResult = false;
            // default is HKLM
            RegistryHive hive = RegistryHive.LocalMachine;

            string subKey = Link.Substring(5, Link.Length-5);
            string path = Target.Substring(5, Target.Length - 5);
            path = String.Concat(@"\Registry\Machine\", path);
            byte[] pathBytes = Encoding.Unicode.GetBytes(path);

            using (SafeRegistryHandle hRoot = new SafeRegistryHandle((IntPtr)hive, true))
            {
                SafeRegistryHandle hKey;
                int lStatus;
                int disposition;
                lStatus = RegCreateKeyEx(hRoot, subKey, 0, String.Empty, REG_OPTION_CREATE_LINK, KEY_WRITE, IntPtr.Zero, out hKey, out disposition);
                bResult = lStatus == ERROR_SUCCESS;
                if (bResult)
                {
                    lStatus = RegSetValueEx(hKey, "SymbolicLinkValue", 0,  REG_LINK, pathBytes, pathBytes.Length);
                    bResult = lStatus == ERROR_SUCCESS;
                    if (bResult)
                    {
                        hKey.Dispose();
                    }
                }
            }

            return bResult;
        }

        public static bool DeleteRegLink(string Link)
        {
            bool bResult = false;

            RegistryHive hive = RegistryHive.LocalMachine;
            string subKey = Link.Substring(5, Link.Length - 5);
            using (SafeRegistryHandle hRoot = new SafeRegistryHandle((IntPtr)hive, true))
            {
                SafeRegistryHandle hKey;
                int lResult = RegOpenKeyEx(hRoot, subKey, REG_OPTION_OPEN_LINK, DELETE, out hKey);
                bResult = lResult == ERROR_SUCCESS;

                if (bResult)
                {
                    int nResult = NtDeleteKey(hKey);
                    bResult = nResult == S_OK;
                    hKey.Dispose();
                }
            }

                return bResult;
        }
    }
}
"@

Add-Type $code

# only supports HKLM as that's what I needed but very easy to adapt...
