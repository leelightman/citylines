import React, {Component} from 'react';
import {browserHistory} from 'react-router';

import CityViewStore from '../../stores/city-view-store';

import {PanelHeader, PanelBody} from '../panel';
import {LinesTreeContainer, LinesTree} from './lines-tree';
import Year from './year';
import KmIndicator from './km-indicator';

class CityView extends Component {
  constructor(props, context) {
    super(props, context);

    this.urlName = this.props.params.city_url_name;

    this.bindedOnChange = this.onChange.bind(this);
    this.bindedOnYearChange = this.onYearChange.bind(this);
    this.bindedOnLineToggle = this.onLineToggle.bind(this);
    this.bindedOnLinesShownChange = this.onLinesShownChange.bind(this);
  }

  onChange() {
    this.setState(CityViewStore.getState(this.urlName));
  }

  componentWillMount() {
    CityViewStore.addChangeListener(this.bindedOnChange);
  }

  componentDidMount() {
    CityViewStore.load(this.urlName, this.params())
  }

  componentWillUnmount() {
    CityViewStore.unload(this.urlName);
    CityViewStore.removeChangeListener(this.bindedOnChange);
  }

  params() {
    return this.props.location.query;
  }

  updateParams(newParams) {
    const params = Object.assign({}, this.params(), newParams);

    // If new params are equal to the current ones, we don't push the state to the
    // browser history
    if (JSON.stringify(params) === JSON.stringify(this.params())) return;

    browserHistory.push({...this.props.location, query: params});
  }

  onYearChange() {
    if (this.state.playing) return;
    const newYear = this.state.currentYear;
    this.updateParams({year: newYear});
    CityViewStore.setKmYear(this.urlName, newYear, null);
  }

  onLineToggle(lineUrlName) {
    CityViewStore.toggleLine(this.urlName, lineUrlName);
  }

  onLinesShownChange() {
    const linesShown = this.state.linesShown.join(',');
    this.updateParams({lines: linesShown});
  }

  render() {
    if (!this.state) return null;

    return (
        <PanelBody>
          <div className="year-and-km-container">
            <Year
              urlName={this.urlName}
              min={(this.state.years || {}).start}
              max={(this.state.years || {}).end}
              year={this.state.currentYear}
              playing={this.state.playing}
              onYearChange={this.bindedOnYearChange}
            />
            <KmIndicator
              kmOperative={this.state.kmOperative}
              kmUnderConstruction={this.state.kmUnderConstruction}
            />
          </div>
          <LinesTreeContainer>
            <LinesTree
              name={'Líneas'}
              defaultExpanded={true}
              lines={this.state.lines}
              linesShown={this.state.linesShown}
              onLineToggle={this.bindedOnLineToggle}
              onLinesShownChange={this.bindedOnLinesShownChange}
            />
          </LinesTreeContainer>
        </PanelBody>
    )
  }
}

export default CityView
