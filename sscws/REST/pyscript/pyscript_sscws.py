#
# NOSA HEADER START
#
# The contents of this file are subject to the terms of the NASA Open
# Source Agreement (NOSA), Version 1.3 only (the "Agreement").  You may
# not use this file except in compliance with the Agreement.
#
# You can obtain a copy of the agreement at
#   docs/NASA_Open_Source_Agreement_1.3.txt
# or
#   https://sscweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
#
# See the Agreement for the specific language governing permissions
# and limitations under the Agreement.
#
# When distributing Covered Code, include this NOSA HEADER in each
# file and include the Agreement file at
# docs/NASA_Open_Source_Agreement_1.3.txt.  If applicable, add the
# following below this NOSA HEADER, with the fields enclosed by
# brackets "[]" replaced with your own identifying information:
# Portions Copyright [yyyy] [name of copyright owner]
#
# NOSA HEADER END
#
# Copyright (c) 2024-2025 United States Government as represented by
# the National Aeronautics and Space Administration. No copyright is
# claimed in the United States under Title 17, U.S.Code. All Other
# Rights Reserved.
#

"""
This Python code demonstrates using the sscws and pyscript Python packages 
to access satellite location information from NASA's Satellite Situation 
Center in an HTML page.
"""

from datetime import datetime, timezone
from typing import Dict

import dateutil.parser
from dateutil.parser import ParserError

import matplotlib as mpl
# suppress output about building font cache
mpl.set_loglevel("critical")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from packaging import version

from sscws.sscws import SscWs

# pyscript related imports
from js import alert, console, document
from pyscript.web import page
from pyscript.web import option
from pyscript import display, window, when


TIME_FMT = '%Y-%m-%dT%H:%M:%S'


def get_observatories(
    ) -> Dict:
    """
    Gets a description of the available SSC observatories.  Also creates
    the corresponding html option dom objects and adds them to the
    satellite select dom object.

    Returns
    -------
    Dict
        Dictionary of available observatories.
    """

    obs = {}
    document.body.style.cursor = 'wait'
    result = ssc.get_observatories()
    document.body.style.cursor = 'default'
    for observatory in result['Observatory']:
        name = observatory['Name']
        obs_id = observatory['Id']
        start_time = observatory['StartTime']
        end_time = observatory['EndTime']
        obs[obs_id] = {
            'name': name,
            'start_time': start_time,
            'end_time': end_time
        }
        sat_option = option()
        sat_option.text = name

        sat_option.value = obs_id
        sat_option.title = observatory['StartTime'].strftime(TIME_FMT) + \
            ' to ' +  observatory['EndTime'].strftime(TIME_FMT)
        if obs_id == 'cluster1' or obs_id == 'cluster2':
            sat_option.selected = 'selected'
        sat_select[0].append(sat_option)
    return obs


def valid_time_range(
        sat: str,
        start_date: datetime,
        end_date: datetime
    ) -> str:
    """
    Determines if the given time range is valid for the specified satellite.

    Parameters
    ----------
    sat
        Satellite identifier.
    start_date
        Beginning of time range to validate.
    end_date
        Ending of time range to validate.

    Returns
    -------
    str
        None if time range if valid.  Otherwise a message indicating that
        the time range if invalid and what the valid range is.
    """

    obs = observatories[sat]

    if start_date >= obs['start_time'] and end_date <= obs['end_time']:
        return None

    return 'Time range outside of data for ' + obs['name'] + \
            '.\n\nIt must be within ' + obs['start_time'].isoformat() + \
            '\nto ' + obs['end_time'].isoformat() + '.'


@when('click', '#plotButton')
def plot_handler(
        event  # pylint: disable=unused-argument
    ) -> None:
    """
    Responds to a plot button press.

    Parameters
    ----------
    event
        HTML DOM event.
    """

    plot_button = page['#plotButton']
    # disable rapid, repeated plots
    plot_button.disabled = True

    selected_sats = []
    for sat_option in page['#satSel'].children[0]:
        if sat_option.selected:
            console.log(f'{sat_option.value}, selected = {sat_option.selected}')
            selected_sats.append(sat_option.value)

    if len(selected_sats) < 1:
        alert('You must select at least one satellite')
        plot_button.disabled = False
        return

    #console.log(f'len(selected_sats) = {len(selected_sats)}')
    #for selected_sat in selected_sats:
    #    window.console.log(selected_sat)

    try:
        start_date = dateutil.parser.parse(page['#startTime'].value[0])
        start_date = start_date.replace(tzinfo=timezone.utc)
    except ParserError:
        alert('Invalid Start Time')
        plot_button.disabled = False
        return

    try:
        stop_date = dateutil.parser.parse(page['#stopTime'].value[0])
        stop_date = stop_date.replace(tzinfo=timezone.utc)
    except ParserError:
        alert('Invalid Stop Time')
        plot_button.disabled = False
        return

    window.console.log(f'''select time: {start_date.isoformat()} ,
         {stop_date.isoformat()}''')

    if start_date >= stop_date:
        alert('Start Time must be less than Stop Time')
        plot_button.disabled = False
        return

    for sat in selected_sats:
        invalid = valid_time_range(sat, start_date, stop_date)
        if invalid is not None:
            alert(invalid)
            plot_button.disabled = False
            return

    document.body.style.cursor = 'wait'
    #result = ssc.get_locations2(selected_sats,
    result = ssc.get_locations(selected_sats,
                               [start_date.isoformat(),
                                stop_date.isoformat()])
    fig = plt.figure()
    if version.parse(mpl.__version__) < version.parse('3.4'):
        ax = fig.gca(projection='3d')
    else:
        ax = Axes3D(fig, auto_add_to_figure=False)
        fig.add_axes(ax)
    ax.set_xlabel('X (km)')
    ax.set_ylabel('Y (km)')
    ax.set_zlabel('Z (km)')

    for data in result['Data']:
        coords = data['Coordinates'][0]

        title = data['Id'] + ' Orbit (' + \
                coords['CoordinateSystem'].value.upper() + ')'
        ax.plot(coords['X'], coords['Y'], coords['Z'], label=title)
        ax.legend()

    display(fig, target="mpl", append=False)
    document.body.style.cursor = 'default'

    plot_button.disabled = False


# SSC web services
ssc = SscWs()

#status = page['#status'][0]
status = document.querySelector('#status')
#console.log(f'status = {status}')
#status_h1 = page['#status > h1']
#status_h1.html = 'Getting Satellites'

# satellite select html dom object
sat_select = page['#satSel']

# Get the available satellites and their time ranges.

observatories = get_observatories()
