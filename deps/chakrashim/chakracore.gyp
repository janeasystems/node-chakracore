{
  'variables': {
    'target_arch%': 'ia32',
    'library%': 'static_library',   # build chakracore as static library or dll
    'component%': 'static_library', # link crt statically or dynamically
    'chakra_dir%': 'core',
    'icu_args%': '',
    'icu_include_path%': '',
    'linker_start_group%': '',
    'linker_end_group%': '',
    'chakra_libs_absolute%': '',
    'chakra_disable_jit%':'false',

    # xplat (non-win32) only
    'chakra_config': '<(chakracore_build_config)',     # Debug, Release, Test
    'chakra_build_flags': ['-v'],

    'conditions': [
      ['target_arch=="ia32"', { 'Platform': 'x86' }],
      ['target_arch=="x64"', {
        'Platform': 'x64',
        'chakra_build_flags+': [ '--arch=amd64' ],
      }],
      ['target_arch=="arm"', {
        'Platform': 'arm',
      }],
      ['target_arch=="arm64"', {
        'Platform': 'arm64',
        'chakra_build_flags+': [ '--arch=arm64' ],
      }],
      ['OS!="win" and v8_enable_i18n_support', {
        'icu_include_path': '../<(icu_path)/source/common'
      }],

      ['OS=="ios"', {
        'chakra_build_flags+': [ '--target=ios' ],
      }],
      # xplat (non-win32) only
      ['chakracore_build_config=="Debug"', {
        'chakra_build_flags': [ '-d' ],
      }, 'chakracore_build_config=="Test"', {
        'chakra_build_flags': [ '-t' ],
      }, {
        'chakra_build_flags': [],
      }],
      ['chakra_disable_jit=="true"', {
        'chakra_build_flags+': [ '--no-jit' ],
      }],
    ],
  },

  'targets': [
    {
      'target_name': 'chakracore',
      'toolsets': ['host'],
      'type': 'none',

      'conditions': [
        ['OS!="win" and v8_enable_i18n_support', {
          'dependencies': [
            '<(icu_gyp_path):icui18n',
            '<(icu_gyp_path):icuuc',
            ],
        }]
      ],
        
      'variables': {
        'chakracore_header': [
          '<(chakra_dir)/lib/Common/ChakraCoreVersion.h',
          '<(chakra_dir)/lib/Jsrt/ChakraCore.h',
          '<(chakra_dir)/lib/Jsrt/ChakraCommon.h',
          '<(chakra_dir)/lib/Jsrt/ChakraCommonWindows.h',
          '<(chakra_dir)/lib/Jsrt/ChakraDebug.h',
        ],

        'chakracore_win_bin_dir':
          '<(chakra_dir)/build/vcbuild/bin/<(Platform)_<(chakracore_build_config)',
        'xplat_dir': '<(chakra_dir)/out/<(chakra_config)',
        'chakra_libs_absolute': '<(PRODUCT_DIR)/../../deps/chakrashim/<(xplat_dir)',

        'conditions': [
          ['OS=="win"', {
            'chakracore_input': '<(chakra_dir)/build/Chakra.Core.sln',
            'chakracore_binaries': [
              '<(chakracore_win_bin_dir)/chakracore.dll',
              '<(chakracore_win_bin_dir)/chakracore.pdb',
              '<(chakracore_win_bin_dir)/chakracore.lib',
            ]
          }],
          ['OS in "linux android"', {
            'chakracore_input': '<(chakra_dir)/build.sh',
            'chakracore_binaries': [
              '<(chakra_libs_absolute)/lib/libChakraCoreStatic.a',
            ],
            'icu_args': '--icu=<(icu_include_path)',
            'linker_start_group': '-Wl,--start-group',
            'linker_end_group': [
              '-Wl,--end-group',
              '-lgcc_s',
            ]
          }],
          ['OS=="mac" or OS=="ios"', {
            'chakracore_input': '<(chakra_dir)/build.sh',
            'chakracore_binaries': [
              '<(chakra_libs_absolute)/lib/libChakraCoreStatic.a',
            ],
            'conditions': [
              ['v8_enable_i18n_support', {
                'icu_args': '--icu=<(icu_include_path)',
              },{
                'icu_args': '--no-icu',
              }],
            ],
            'linker_start_group': '-Wl,-force_load',
          }]
        ],
      },

      'actions': [
        {
          'action_name': 'build_chakracore',
          'inputs': [
            '<(chakracore_input)',
          ],
          'outputs': [
            '<@(chakracore_binaries)',
          ],
          'conditions': [
            ['OS=="win"', {
              'action': [
                'msbuild',
                '/p:Platform=<(Platform)',
                '/p:Configuration=<(chakracore_build_config)',
                '/p:RuntimeLib=<(component)',
                '/p:AdditionalPreprocessorDefinitions=COMPILE_DISABLE_Simdjs=1',
                '/m',
                '<@(_inputs)',
              ],
            }, {
              'action': [
                'bash',
                '<(chakra_dir)/build.sh',
                '--without=Simdjs',
                '--static',
                '<@(chakracore_parallel_build_flags)',
                '<@(chakracore_lto_build_flags)',
                '<@(chakra_build_flags)',
                '<@(icu_args)',
                '--libs-only'
              ],
            }],
          ],
        },
      ],

      'copies': [
        {
          'destination': 'include',
          'files': [ '<@(chakracore_header)' ],
        },
        {
          'destination': '<(PRODUCT_DIR)',
          'files': [ '<@(chakracore_binaries)' ],
        },
      ],

      'direct_dependent_settings': {
        'library_dirs': [ '<(PRODUCT_DIR)' ],
        'conditions': [
          ['OS=="win"', {
          }, {
            'conditions': [
              ['OS=="mac" or OS=="ios"', {
                'libraries': [
                  '-framework CoreFoundation',
                  '-framework Security',
                ]
              }]
            ],
            'libraries': [
              '-Wl,-undefined,error',
              '<@(linker_start_group)',
              '<(chakra_libs_absolute)/lib/libChakraCoreStatic.a ' # keep this single space.
              '<@(linker_end_group)',                                         # gpy fails to patch with list
            ],
          }],
        ],
      },

    }, # end chakracore
  ],
}
