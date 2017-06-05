# -*- Mode:Python; indent-tabs-mode:nil; tab-width:4 -*-
#
# Copyright (C) 2015-2016 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""The catkin_tools build plugin is useful for building ROS parts.

This plugin relies on the catkin plugin as the catkin plugin performs
configuration that allows catkin_tools to run.  This plugin uses the
same keywords and configurations as the catkin plugin, the difference
is the installation of and using catkin_tools to build.
"""

import os
import logging

import snapcraft.plugins.catkin
from snapcraft.plugins.catkin import (
    Compilers,
)

import snapcraft

logger = logging.getLogger(__name__)


class CatkinToolsPlugin(snapcraft.plugins.catkin.CatkinPlugin):
    def build(self):
        """Build Catkin packages.

        This function runs some pre-build steps to prepare the sources for
        building in the Snapcraft environment, builds the packages via
        catkin build, and finally runs some post-build clean steps to
        prepare the newly-minted install to be packaged as a .snap.
        """

        snapcraft.BasePlugin.build(self)

        logger.info('Preparing to build Catkin packages...')
        self._prepare_build()

        logger.info('Building Catkin packages...')
        self._build_catkin_packages()

        logger.info('Cleaning up newly installed Catkin packages...')
        self._finish_build()

    def _prepare_build(self):
        super()._prepare_build()

        # Use catkin config to set all configurations before running build.
        catkincmd = ['catkin']

        catkincmd.extend(['config'])

        # Install the package
        catkincmd.append('--install')

        # Don't clutter the real ROS workspace-- use the Snapcraft build
        # directory
        catkincmd.extend(['--build-space', self.builddir])

        # Account for a non-default source space by always specifying it
        catkincmd.extend(['--source-space', os.path.join(
            self.builddir, self.options.source_space)])

        # Specify that the package should be installed along with the rest of
        # the ROS distro.
        catkincmd.extend(['--install-space', self.rosdir])

        compilers = Compilers(
            self._compilers_path, self.PLUGIN_STAGE_SOURCES, self.project)

        # All the arguments that follow are meant for CMake
        catkincmd.append('--cmake-args')

        catkincmd.extend([
            '-DCMAKE_C_FLAGS="$CFLAGS {}"'.format(compilers.cflags),
            '-DCMAKE_CXX_FLAGS="$CPPFLAGS {}"'.format(compilers.cxxflags),
            '-DCMAKE_LD_FLAGS="$LDFLAGS {}"'.format(compilers.ldflags),
            '-DCMAKE_C_COMPILER={}'.format(compilers.c_compiler_path),
            '-DCMAKE_CXX_COMPILER={}'.format(compilers.cxx_compiler_path)
        ])

        self._run_in_bash(catkincmd)

    def _build_catkin_packages(self):
        # Nothing to do if no packages were specified
        if not self.catkin_packages:
            return

        catkincmd = ['catkin']

        catkincmd.extend(['build'])

        catkincmd.extend(self.catkin_packages)

        compilers = Compilers(
            self._compilers_path, self.PLUGIN_STAGE_SOURCES, self.project)

        # This command must run in bash due to a bug in Catkin that causes it
        # to explode if there are spaces in the cmake args (which there are).
        self._run_in_bash(catkincmd, env=compilers.environment)
