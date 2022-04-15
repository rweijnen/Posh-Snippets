Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using NET_API_STATUS = System.UInt32;

namespace WinApi
{
	public class LocalGroup
	{
		private List<string> _members = null;
		private string _name;
		private string _comment;
		public LocalGroup(string Name, string Comment)
		{
			_name = Name;
			_comment = Comment;
		}

		public string Name { get { return _name; } }
		public string Comment { get { return _comment; } }
		public List<String> Members
		{
			get
			{
				if (null == _members)
                {
					_members = NetApi32.GetGroupMembers(Name);
				}

				return _members;
			}
		}
	}

	public static class NetApi32
	{

		const uint MAX_PREFERRED_LENGTH = 0xFFFFFFFF;
		const uint NERR_Success = 0;

		public static List<LocalGroup> GetLocalGroups()
		{
			List<LocalGroup> result = new List<LocalGroup>();
			IntPtr bufptr;
			uint entriesread = 0;
			uint totalentries = 0;
			NET_API_STATUS nas;
			nas = NetLocalGroupEnum(IntPtr.Zero, 1, out bufptr, MAX_PREFERRED_LENGTH, ref entriesread, ref totalentries, IntPtr.Zero);
			if (nas == NERR_Success)
			{
				LOCALGROUP_INFO_1 lgi;
				IntPtr current = bufptr;
				string name;
				string comment;
				try
				{
					for (int i = 0; i < entriesread; i++)
					{
						lgi = (LOCALGROUP_INFO_1)Marshal.PtrToStructure(current, typeof(LOCALGROUP_INFO_1));
						name = Marshal.PtrToStringAuto(lgi.lpszGroupName);
						comment = Marshal.PtrToStringAuto(lgi.lpszComment);

						result.Add(new LocalGroup(name, comment));
						current = new IntPtr(current.ToInt64() + Marshal.SizeOf(lgi));
					}
				}
				finally
				{
					NetApiBufferFree(bufptr);
				}
			}

			return result;
		}

		public static List<String> GetGroupMembers(string Groupname)
		{
			List<String> result = new List<string>();
			NET_API_STATUS nas;
			IntPtr bufptr;
			uint entriesread = 0;
			uint totalentries = 0;

			nas = NetLocalGroupGetMembers(IntPtr.Zero, Groupname, 1, out bufptr, MAX_PREFERRED_LENGTH, ref entriesread, ref totalentries, IntPtr.Zero);
			if (nas == NERR_Success)
			{
				IntPtr current = bufptr;
				string username;
				try
				{
					LOCALGROUP_MEMBERS_INFO_1 lgmi;
					for (int i = 0; i < entriesread; i++)
					{
						lgmi = (LOCALGROUP_MEMBERS_INFO_1)Marshal.PtrToStructure(current, typeof(LOCALGROUP_MEMBERS_INFO_1));
						username = Marshal.PtrToStringAuto(lgmi.lgrmi1_name);
						result.Add(username);
						current = new IntPtr(current.ToInt64() + Marshal.SizeOf(lgmi));
					}
				}
				finally
				{
					NetApiBufferFree(bufptr);
				}
			}

			return result;
		}

		[DllImport("netapi32.dll", EntryPoint = "NetApiBufferFree")]
		internal static extern void NetApiBufferFree(IntPtr bufptr);

		[DllImport("netapi32.dll", EntryPoint = "NetLocalGroupGetMembers", SetLastError = false)]
		internal static extern uint NetLocalGroupGetMembers(
			IntPtr servername,
			[MarshalAs(UnmanagedType.LPWStr)]
		string localgroupname,
			uint level,
			out IntPtr bufptr,
			uint prefmaxlen,
			ref uint entriesread,
			ref uint totalentries,
			IntPtr resumehandle);

		[DllImport("netapi32.dll", EntryPoint = "NetLocalGroupEnum", SetLastError = false)]
		internal static extern uint NetLocalGroupEnum(
			IntPtr servername,
					uint level,
					out IntPtr bufptr,
					uint prefmaxlen,
					ref uint entriesread,
					ref uint totalentries,
					IntPtr resumehandle);

		[StructLayoutAttribute(LayoutKind.Sequential, CharSet = CharSet.Auto)]
		internal struct LOCALGROUP_MEMBERS_INFO_1
		{
			public IntPtr lgrmi1_sid;
			public IntPtr lgrmi1_sidusage;
			public IntPtr lgrmi1_name;

		}

		[StructLayoutAttribute(LayoutKind.Sequential, CharSet = CharSet.Auto)]
		internal struct LOCALGROUP_INFO_1
		{
			public IntPtr lpszGroupName;
			public IntPtr lpszComment;
		}
	}

}
"@

[WinApi.NetApi32]::GetLocalGroups()
