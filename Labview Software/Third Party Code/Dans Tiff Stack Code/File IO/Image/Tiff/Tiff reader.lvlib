<?xml version='1.0' encoding='UTF-8'?>
<Library LVVersion="18008000">
	<Property Name="Alarm Database Computer" Type="Str">localhost</Property>
	<Property Name="Alarm Database Name" Type="Str">C__Program_Files_National_Instruments_LabVIEW_8_6_data</Property>
	<Property Name="Alarm Database Path" Type="Str">C:\Program Files\National Instruments\LabVIEW 8.6\data</Property>
	<Property Name="Data Lifespan" Type="UInt">3650</Property>
	<Property Name="Database Computer" Type="Str">localhost</Property>
	<Property Name="Database Name" Type="Str">C__Program_Files_National_Instruments_LabVIEW_8_6_data</Property>
	<Property Name="Database Path" Type="Str">C:\Program Files\National Instruments\LabVIEW 8.6\data</Property>
	<Property Name="Enable Alarms Logging" Type="Bool">true</Property>
	<Property Name="Enable Data Logging" Type="Bool">true</Property>
	<Property Name="NI.Lib.Description" Type="Str">Library for reading and writing TIFF files with the ability to "stream" to disk, read/write metadata, and read/write float image types.

This work was based off of freely available code at :http://forums.lavag.org/TIFF-Reader-t10250.html</Property>
	<Property Name="NI.Lib.HelpPath" Type="Str"></Property>
	<Property Name="NI.Lib.Icon" Type="Bin">'!#!!!!!!!)!"1!&amp;!!!-!%!!!@````]!!!!"!!%!!!(]!!!*Q(C=\&gt;7R=2MR%!81N=?"5X&lt;A91M&lt;/W-,&lt;'&amp;&lt;9+K1,7Q,&lt;)%N&lt;!NMA3X)DW?-RJ(JQ"I\%%Z,(@`BA#==ZB3RN;]28_,V7@P_W`:R`&gt;HV*SU_WE@\N_XF[3:^^TX\+2YP)D7K6;G-RV3P)R`ZS%=_]J'XP/5N&lt;XH,7V\SEJ?]Z#5P?=J4HP+5JTTFWS%0?=B$DD1G(R/.1==!IT.+D)`B':\B'2Z@9XC':XC':XBUC?%:HO%:HO&amp;R7QT0]!T0]!S0I4&lt;*&lt;)?=:XA-(]X40-X40-VDSGC?"GC4N9(&lt;)"D2,L;4ZGG?ZH%;T&gt;-]T&gt;-]T?.S.%`T.%`T.)^&lt;NF8J4@-YZ$S'C?)JHO)JHO)R&gt;"20]220]230[;*YCK=ASI2F=)1I.Z5/Z5PR&amp;)^@54T&amp;5TT&amp;5TQO&lt;5_INJ6Z;"[(H#&gt;ZEC&gt;ZEC&gt;Z$"(*ETT*ETT*9^B)HO2*HO2*(F.&amp;]C20]C2)GN4UE1:,.[:/+5A?0^NOS?UJ^3&lt;*\9B9GT@7JISVW7*NIFC&lt;)^:$D`5Q9TWE7)M@;V&amp;D,6;M29DVR]6#R],%GC47T9_/=@&gt;Z5V&gt;V57&gt;V5E&gt;V5(OV?^T[FTP?\`?YX7ZRP6\D=LH%_8S/U_E5R_-R$I&gt;$\0@\W/VW&lt;[_"&lt;Y[X&amp;],0^^+,]T_J&gt;`J@_B_]'_.T`$KO.@I"O[^NF!!!!!!</Property>
	<Property Name="NI.Lib.SourceVersion" Type="Int">402685952</Property>
	<Property Name="NI.Lib.Version" Type="Str">1.0.0.0</Property>
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">true</Property>
	<Property Name="NI.SortType" Type="Int">3</Property>
	<Property Name="Serialized ACL" Type="Bin">'!#!!!!!!!)!"1!&amp;!!!A1%!!!@````]!!".V&lt;H.J:WZF:#"C?82F)'&amp;S=G&amp;Z!!%!!1!!!!A)!!!!#!!!!!!!!!!</Property>
	<Property Name="Use Data Logging Database" Type="Bool">true</Property>
	<Item Name="Load" Type="Folder">
		<Item Name="Load stack of I16 images with metadata from Tiff Stack file.vi" Type="VI" URL="../Load stack of I16 images with metadata from Tiff Stack file.vi"/>
		<Item Name="Load stack of U16 images with metadata from Tiff Stack file.vi" Type="VI" URL="../Load stack of U16 images with metadata from Tiff Stack file.vi"/>
		<Item Name="Load one I16bit Image with metadata from Tiff Stack file.vi" Type="VI" URL="../Load one I16bit Image with metadata from Tiff Stack file.vi"/>
		<Item Name="Load one U16 Image with metadata from Tiff Stack file.vi" Type="VI" URL="../Load one U16 Image with metadata from Tiff Stack file.vi"/>
		<Item Name="Find slice locations from file.vi" Type="VI" URL="../Find slice locations from file.vi"/>
	</Item>
	<Item Name="Save" Type="Folder">
		<Item Name="Save single image with metadata to Tiff file.vi" Type="VI" URL="../Save single image with metadata to Tiff file.vi"/>
		<Item Name="Save multiple images with metadata to new tiff stack.vi" Type="VI" URL="../Save multiple images with metadata to new tiff stack.vi"/>
		<Item Name="Append tiff file with existing Tiff file or Tiff string.vi" Type="VI" URL="../Append tiff file with existing Tiff file or Tiff string.vi"/>
		<Item Name="Save image to Tiff stack file.vi" Type="VI" URL="../Save image to Tiff stack file.vi"/>
	</Item>
	<Item Name="Utilites" Type="Folder">
		<Item Name="Get image dimensions from Tiff file.vi" Type="VI" URL="../Get image dimensions from Tiff file.vi"/>
		<Item Name="Get number of images in a Tiff stack file.vi" Type="VI" URL="../Get number of images in a Tiff stack file.vi"/>
	</Item>
	<Item Name="Low Level" Type="Folder">
		<Item Name="Conversion" Type="Folder">
			<Item Name="Bytes to long word.vi" Type="VI" URL="../Bytes to long word.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Bytes to word.vi" Type="VI" URL="../Bytes to word.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Long word to bytes.vi" Type="VI" URL="../Long word to bytes.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="U16ToType.vi" Type="VI" URL="../U16ToType.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Word to bytes.vi" Type="VI" URL="../Word to bytes.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Convert I64 to U32 with error if overflow.vi" Type="VI" URL="../Convert I64 to U32 with error if overflow.vi"/>
			<Item Name="Read Array from file.vi" Type="VI" URL="../Read Array from file.vi"/>
		</Item>
		<Item Name="Tags" Type="Folder">
			<Item Name="FieldTypes.ctl" Type="VI" URL="../FieldTypes.ctl">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Get Tag Value.vi" Type="VI" URL="../Get Tag Value.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Get Tag Value from file.vi" Type="VI" URL="../Get Tag Value from file.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Replace Tag.vi" Type="VI" URL="../Replace Tag.vi"/>
			<Item Name="Search for tag.vi" Type="VI" URL="../Search for tag.vi"/>
			<Item Name="Set Pixel Resolution Unit.vi" Type="VI" URL="../Set Pixel Resolution Unit.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Set Pixel Size in Tag Value.vi" Type="VI" URL="../Set Pixel Size in Tag Value.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Shift Tag Offsets.vi" Type="VI" URL="../Shift Tag Offsets.vi"/>
			<Item Name="Shift Tag offsets for newly inserted data.vi" Type="VI" URL="../Shift Tag offsets for newly inserted data.vi"/>
			<Item Name="Shift Tags for newly inserted tag.vi" Type="VI" URL="../Shift Tags for newly inserted tag.vi"/>
			<Item Name="Insert Tag.vi" Type="VI" URL="../Insert Tag.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Change the pixel size in Tiff file metadata.vi" Type="VI" URL="../Change the pixel size in Tiff file metadata.vi"/>
		</Item>
		<Item Name="IFD" Type="Folder">
			<Item Name="IFD Entry.ctl" Type="VI" URL="../IFD Entry.ctl"/>
			<Item Name="Big or Little Endian.vi" Type="VI" URL="../Big or Little Endian.vi"/>
			<Item Name="Find all IFD locations from file.vi" Type="VI" URL="../Find all IFD locations from file.vi"/>
			<Item Name="Find last IFD.vi" Type="VI" URL="../Find last IFD.vi"/>
			<Item Name="Get Location of next IFD from file.vi" Type="VI" URL="../Get Location of next IFD from file.vi"/>
			<Item Name="Get Location of next IFD.vi" Type="VI" URL="../Get Location of next IFD.vi"/>
			<Item Name="Read Header from file.vi" Type="VI" URL="../Read Header from file.vi"/>
			<Item Name="Read Header.vi" Type="VI" URL="../Read Header.vi"/>
			<Item Name="Read IFD Entry from file.vi" Type="VI" URL="../Read IFD Entry from file.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Read IFD Entry.vi" Type="VI" URL="../Read IFD Entry.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Read Image File Directories and Tags from file.vi" Type="VI" URL="../Read Image File Directories and Tags from file.vi"/>
			<Item Name="Read Image File Directory.vi" Type="VI" URL="../Read Image File Directory.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Set IFD Entry.vi" Type="VI" URL="../Set IFD Entry.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
		</Item>
		<Item Name="Appending" Type="Folder">
			<Item Name="Append tiff file strings.vi" Type="VI" URL="../Append tiff file strings.vi"/>
			<Item Name="Write new location of new page to previous page.vi" Type="VI" URL="../Write new location of new page to previous page.vi"/>
			<Item Name="Shift Header to point to starting tag.vi" Type="VI" URL="../Shift Header to point to starting tag.vi"/>
		</Item>
		<Item Name="Load" Type="Folder">
			<Item Name="Generate Colour Table.vi" Type="VI" URL="../Generate Colour Table.vi">
				<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
			</Item>
			<Item Name="Load 16bit Image Stack from Tiff.vi" Type="VI" URL="../Load 16bit Image Stack from Tiff.vi"/>
			<Item Name="Load Flattened 32bit float Image from Tiff.vi" Type="VI" URL="../Load Flattened 32bit float Image from Tiff.vi"/>
			<Item Name="Load Tiff image from data.vi" Type="VI" URL="../Load Tiff image from data.vi"/>
			<Item Name="Load I16 image data for single image from TIF stack file.vi" Type="VI" URL="../Load I16 image data for single image from TIF stack file.vi"/>
			<Item Name="Load U16 image data for single image from TIF stack file.vi" Type="VI" URL="../Load U16 image data for single image from TIF stack file.vi"/>
			<Item Name="Read Single I16 Image and Metadata from file.vi" Type="VI" URL="../Read Single I16 Image and Metadata from file.vi"/>
			<Item Name="Read Single U16 Image and Metadata from file.vi" Type="VI" URL="../Read Single U16 Image and Metadata from file.vi"/>
		</Item>
		<Item Name="Metadata" Type="Folder">
			<Item Name="Create metadata Tag Cluster.vi" Type="VI" URL="../Create metadata Tag Cluster.vi"/>
			<Item Name="Image with metadata to Tiff file string.vi" Type="VI" URL="../Image with metadata to Tiff file string.vi"/>
			<Item Name="Metadata tag number.vi" Type="VI" URL="../Metadata tag number.vi"/>
			<Item Name="Read metadata from tiff string.vi" Type="VI" URL="../Read metadata from tiff string.vi"/>
			<Item Name="Write metadata to tiff string.vi" Type="VI" URL="../Write metadata to tiff string.vi"/>
			<Item Name="test metadata.vi" Type="VI" URL="../test metadata.vi"/>
		</Item>
		<Item Name="ImageDescription" Type="Folder">
			<Item Name="Write ImageDescription to tiff string.vi" Type="VI" URL="../Write ImageDescription to tiff string.vi"/>
			<Item Name="ImageDescription tag number.vi" Type="VI" URL="../ImageDescription tag number.vi"/>
			<Item Name="Read ImageDescription from tiff file or string.vi" Type="VI" URL="../Read ImageDescription from tiff file or string.vi"/>
		</Item>
	</Item>
</Library>
