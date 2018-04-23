import axios, { CancelTokenSource } from "axios";
import * as React from "react";

import {Async as AsyncSelect, ReactAsyncSelectProps} from "react-select";
import "react-select/scss/default.scss";

declare module "react-select" {
  interface ReactAsyncSelectProps<TValue = OptionValues> {
    searchPromptText?: any;
  }
}

export interface AutocompleteProps {
  /**
   * The name of the input to be submitted with the form
   */
  name: string;
  /**
   * The value of the actually selected option
   */
  selected: any;
  /**
   * An array objects with the preloded options (needs to include the selected option)
   */
  options: object[];
  /**
   * placeholder displayed when there are no matching search results or a falsy value to hide it
   */
  noResultsText?: string;
  /**
   * field placeholder, displayed when there's no value
   */
  placeholder: string;
  /**
   * label to prompt for search input
   */
  searchPromptText?: string;
  /**
   * The URL where fetch content
   */
  searchURL: string;
}

interface AutocompleteState {
  selectedOption: any;
}

export class Autocomplete extends React.Component<AutocompleteProps, AutocompleteState> {
  public static defaultProps: any = {
    autoload: false
  };

  private cancelTokenSource: CancelTokenSource;

  constructor(props: AutocompleteProps) {
    super(props);

    this.state = {
      selectedOption: props.selected
    };
  }

  public render(): JSX.Element {
    const { selectedOption } = this.state;
    const { name, placeholder, searchPromptText, noResultsText, options } = this.props;

    return (
      <AsyncSelect
        name={name}
        value={selectedOption}
        options={options}
        placeholder={placeholder}
        searchPromptText={searchPromptText}
        noResultsText={noResultsText}
        onChange={this.handleChange}
        loadOptions={this.loadOptions}
        filterOptions={this.filterOptions}
        autoload={false}
        removeSelected={true}
        escapeClearsValue={false}
        onCloseResetsInput={false}
      />
    );
  }

  private handleChange = (selectedOption: any) => {
    this.setState({ selectedOption });
  }

  private filterOptions = (options: any, filter: any, excludeOptions: any) => {
    // Do no filtering, just return all options because
    // we return a filtered set from server
    return options;
  }

  private loadOptions = (input: string, callback: any) => {
    input = input.toLowerCase();

    if (this.cancelTokenSource) {
      this.cancelTokenSource.cancel();
    }

    if (input.length < 3) {
      callback (null, { options: [], complete: false });
    } else {
      this.cancelTokenSource = axios.CancelToken.source();

      axios.get(this.props.searchURL, {
        cancelToken: this.cancelTokenSource.token,
        headers: {
          Accept: "application/json"
        },
        withCredentials: true,
        params: {
          term: input
        }
      })
      .then((response) => {
        // CAREFUL! Only set complete to true when there are no more options,
        // or more specific queries will not be sent to the server.
        callback (null, { options: response.data, complete: true });
      })
      .catch((error: any) => {
        if (axios.isCancel(error)) {
          console.log('Request canceled', error.message);
        } else {
          callback (error, { options: [], complete: false });
        }
      });
    }
  }
}

export default Autocomplete;
