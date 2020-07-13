## @file
#  Cryptographic Library Package for UEFI Security Implementation.
#  PEIM, DXE Driver, and SMM Driver with all crypto services enabled.
#
#  Copyright (c) 2009 - 2020, Intel Corporation. All rights reserved.<BR>
#  Copyright (c) 2020, Hewlett Packard Enterprise Development LP. All rights reserved.<BR>
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = CryptoPkg
  PLATFORM_GUID                  = E1063286-6C8C-4c25-AEF0-67A9A5B6E6B6
  PLATFORM_VERSION               = 0.98
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/CryptoPkg
  SUPPORTED_ARCHITECTURES        = IA32|X64|ARM|AARCH64|RISCV64
  BUILD_TARGETS                  = DEBUG|RELEASE|NOOPT
  SKUID_IDENTIFIER               = DEFAULT

  #
  # Whether to build BCOP or not
  #   CI              - Package verification build of all components.  Null
  #                     versions of libraries are used to minimize build times.
  #   PACKAGE         - Build PEIM, DXE, and SMM drivers.  Protocols and PPIs
  #                     publish all services.
  #
  DEFINE CRYPTO_SERVICES = PACKAGE
!if $(CRYPTO_SERVICES) IN "PACKAGE CI"
!else
  !error CRYPTO_SERVICES must be set to one of PACKAGE CI.
!endif

################################################################################
#
# Library Class section - list of all Library Classes needed by this Platform.
#
################################################################################
[LibraryClasses]
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  UefiDriverEntryPoint|MdePkg/Library/UefiDriverEntryPoint/UefiDriverEntryPoint.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLibNull/BaseCryptLibNull.inf
  TlsLib|CryptoPkg/Library/TlsLibNull/TlsLibNull.inf
  HashApiLib|CryptoPkg/Library/BaseHashApiLib/BaseHashApiLib.inf

[LibraryClasses.ARM, LibraryClasses.AARCH64]
  #
  # It is not possible to prevent the ARM compiler for generic intrinsic functions.
  # This library provides the instrinsic functions generate by a given compiler.
  # [LibraryClasses.ARM, LibraryClasses.AARCH64] and NULL mean link this library
  # into all ARM and AARCH64 images.
  #
  NULL|ArmPkg/Library/CompilerIntrinsicsLib/CompilerIntrinsicsLib.inf

  # Add support for stack protector
  NULL|MdePkg/Library/BaseStackCheckLib/BaseStackCheckLib.inf

[LibraryClasses.common.PEIM]
  PeimEntryPoint|MdePkg/Library/PeimEntryPoint/PeimEntryPoint.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf
  PeiServicesLib|MdePkg/Library/PeiServicesLib/PeiServicesLib.inf
  HobLib|MdePkg/Library/PeiHobLib/PeiHobLib.inf

[LibraryClasses.common.DXE_SMM_DRIVER]
  SmmServicesTableLib|MdePkg/Library/SmmServicesTableLib/SmmServicesTableLib.inf
  MemoryAllocationLib|MdePkg/Library/SmmMemoryAllocationLib/SmmMemoryAllocationLib.inf

# Library Classes to use if we are doing an actual crypto build
!if $(CRYPTO_SERVICES) == "PACKAGE"
[LibraryClasses]
  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  DebugLib|MdeModulePkg/Library/PeiDxeDebugLibReportStatusCode/PeiDxeDebugLibReportStatusCode.inf
  DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
  OemHookStatusCodeLib|MdeModulePkg/Library/OemHookStatusCodeLibNull/OemHookStatusCodeLibNull.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  DevicePathLib|MdePkg/Library/UefiDevicePathLib/UefiDevicePathLib.inf
  PcdLib|MdePkg/Library/DxePcdLib/DxePcdLib.inf
  TimerLib|MdePkg/Library/BaseTimerLibNullTemplate/BaseTimerLibNullTemplate.inf
  UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf
  IoLib|MdePkg/Library/BaseIoLibIntrinsic/BaseIoLibIntrinsic.inf
  OpensslLib|CryptoPkg/Library/OpensslLib/OpensslLib.inf
  IntrinsicLib|CryptoPkg/Library/IntrinsicLib/IntrinsicLib.inf
  SafeIntLib|MdePkg/Library/BaseSafeIntLib/BaseSafeIntLib.inf

[LibraryClasses.ARM]
  ArmSoftFloatLib|ArmPkg/Library/ArmSoftFloatLib/ArmSoftFloatLib.inf

[LibraryClasses.common.PEIM]
  PcdLib|MdePkg/Library/PeiPcdLib/PeiPcdLib.inf
  ReportStatusCodeLib|MdeModulePkg/Library/PeiReportStatusCodeLib/PeiReportStatusCodeLib.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLib/PeiCryptLib.inf
  TlsLib|CryptoPkg/Library/TlsLibNull/TlsLibNull.inf

[LibraryClasses.IA32.PEIM, LibraryClasses.X64.PEIM]
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLibIdt/PeiServicesTablePointerLibIdt.inf

[LibraryClasses.ARM.PEIM, LibraryClasses.AARCH64.PEIM]
  PeiServicesTablePointerLib|ArmPkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf

[LibraryClasses.common.DXE_DRIVER]
  ReportStatusCodeLib|MdeModulePkg/Library/DxeReportStatusCodeLib/DxeReportStatusCodeLib.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLib/BaseCryptLib.inf
  TlsLib|CryptoPkg/Library/TlsLib/TlsLib.inf

[LibraryClasses.common.DXE_SMM_DRIVER]
  ReportStatusCodeLib|MdeModulePkg/Library/SmmReportStatusCodeLib/SmmReportStatusCodeLib.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLib/SmmCryptLib.inf
  TlsLib|CryptoPkg/Library/TlsLibNull/TlsLibNull.inf
!endif

################################################################################
#
# Pcd Section - list of all EDK II PCD Entries defined by this Platform
#
################################################################################
[PcdsFixedAtBuild]
  gEfiMdePkgTokenSpaceGuid.PcdDebugPropertyMask|0x0f
  gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel|0x80000000
  gEfiMdePkgTokenSpaceGuid.PcdReportStatusCodePropertyMask|0x06

###################################################################################################
#
# Components Section - list of the modules and components that will be processed by compilation
#                      tools and the EDK II tools to generate PE32/PE32+/Coff image files.
#
# Note: The EDK II DSC file is not used to specify how compiled binary images get placed
#       into firmware volume images. This section is just a list of modules to compile from
#       source into UEFI-compliant binaries.
#       It is the FDF file that contains information on combining binary files into firmware
#       volume images, whose concept is beyond UEFI and is described in PI specification.
#       Binary modules do not need to be listed in this section, as they should be
#       specified in the FDF file. For example: Shell binary (Shell_Full.efi), FAT binary (Fat.efi),
#       Logo (Logo.bmp), and etc.
#       There may also be modules listed in this section that are not required in the FDF file,
#       When a module listed here is excluded from FDF file, then UEFI-compliant binary will be
#       generated for it, but the binary will not be put into any firmware volume.
#
###################################################################################################

[Components]
  CryptoPkg/Library/BaseCryptLib/BaseCryptLib.inf
  CryptoPkg/Library/BaseCryptLib/PeiCryptLib.inf
  CryptoPkg/Library/BaseCryptLib/SmmCryptLib.inf
  CryptoPkg/Library/BaseCryptLib/RuntimeCryptLib.inf
  CryptoPkg/Library/BaseCryptLibNull/BaseCryptLibNull.inf
  CryptoPkg/Library/IntrinsicLib/IntrinsicLib.inf
  CryptoPkg/Library/TlsLib/TlsLib.inf
  CryptoPkg/Library/TlsLibNull/TlsLibNull.inf
  CryptoPkg/Library/OpensslLib/OpensslLib.inf
  CryptoPkg/Library/OpensslLib/OpensslLibCrypto.inf
  CryptoPkg/Library/BaseHashApiLib/BaseHashApiLib.inf

  CryptoPkg/Library/BaseCryptLibOnProtocolPpi/PeiCryptLib.inf
  CryptoPkg/Library/BaseCryptLibOnProtocolPpi/DxeCryptLib.inf
  CryptoPkg/Library/BaseCryptLibOnProtocolPpi/SmmCryptLib.inf

!if $(CRYPTO_SERVICES) == "CI"
  CryptoPkg/Driver/BaseCryptDriver/CryptoPei.inf
  CryptoPkg/Driver/BaseCryptDriver/CryptoDxe.inf
  CryptoPkg/Driver/BaseCryptDriver/CryptoSmm.inf
!endif

!if $(CRYPTO_SERVICES) == "PACKAGE"
[Defines]
  # Phase Guids
  DEFINE PEI_GUID_PART = 8DF53C2E-3380-495F-A8B7
  DEFINE DXE_GUID_PART = D9444B06-060D-42C5-9344
  DEFINE SMM_GUID_PART = A3542CE8-77F7-49DC-A834
  # Flavor GUIDS
  DEFINE ALL_GUID_PART         = 370CFE28E1C6
  DEFINE MIN_PEI_GUID_PART     = 9BAFCE594D31
  DEFINE MIN_DXE_SMM_GUID_PART = 82B84B5763A2
  DEFINE NONE_GUID_PART        = 6BE0C8A6C7DF

[Components.IA32, Components.X64, Components.ARM, Components.AARCH64]

  CryptoPkg/Driver/BaseCryptDriver/CryptoPei.inf {
    <Defines>
      FILE_GUID = $(PEI_GUID_PART)-$(ALL_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/ALL.dsc.inc
  }
  CryptoPkg/Driver/BaseCryptDriver/CryptoPei.inf {
    <Defines>
      FILE_GUID = $(PEI_GUID_PART)-$(MIN_PEI_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/MIN_PEI.dsc.inc
  }

  CryptoPkg/Driver/BaseCryptDriver/CryptoPei.inf {
    <Defines>
      FILE_GUID = $(PEI_GUID_PART)-$(NONE_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/NONE.dsc.inc
  }

  CryptoPkg/Driver/BaseCryptDriver/CryptoDxe.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(ALL_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/ALL.dsc.inc
  }
  CryptoPkg/Driver/BaseCryptDriver/CryptoDxe.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(NONE_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/NONE.dsc.inc
  }
  CryptoPkg/Driver/BaseCryptDriver/CryptoDxe.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(MIN_PEI_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/MIN_PEI.dsc.inc
  }
  CryptoPkg/Driver/BaseCryptDriver/CryptoDxe.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(MIN_DXE_SMM_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/MIN_DXE_MIN_SMM.dsc.inc
  }

[Components.IA32, Components.X64, Components.AARCH64]

  CryptoPkg/Driver/BaseCryptDriver/CryptoSmm.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(ALL_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/ALL.dsc.inc
  }
   CryptoPkg/Driver/BaseCryptDriver/CryptoSmm.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(MIN_PEI_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/MIN_PEI.dsc.inc
  }
   CryptoPkg/Driver/BaseCryptDriver/CryptoSmm.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(MIN_DXE_SMM_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/MIN_DXE_MIN_SMM.dsc.inc
  }
   CryptoPkg/Driver/BaseCryptDriver/CryptoSmm.inf {
    <Defines>
      FILE_GUID = $(DXE_GUID_PART)-$(NONE_GUID_PART)
    <PcdsFixedAtBuild>
      !include CryptoPkg/Driver/BaseCryptDriver/Flavors/NONE.dsc.inc
  }
!endif

[BuildOptions]
  *_*_*_CC_FLAGS = -D DISABLE_NEW_DEPRECATED_INTERFACES
