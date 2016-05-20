classdef legtools
    % LEGTOOLS is a MATLAB class definition providing the user with a set of
    % methods to modify existing Legend objects.
    %
    % This is an HG2 specific implementation and requires MATLAB R2014b or
    % newer.
    %
    % legtools methods:
    %      append  - Add one or more entries to the end of the legend
    %      permute - Rearrange the legend entries
    %      remove  - Remove one or more legend entries
    %
    % See also legend
    
    methods
        function obj = legtools
            % Dummy constructor so we don't return an empty class instance
            clear obj
        end
    end
    
    methods (Static)
        function append(lh, newStrings)
            % APPEND appends strings, newStrings, to the specified Legend
            % object, lh. newStrings can be a 1D character array or a 1D
            % cell array of strings. Character arrays are treated as a
            % single string. If multiple Legend objects are specified, only
            % the first will be modified.
            %
            % The legend will only be updated with the new strings if the
            % number of strings in the existing legend plus the number of
            % strings in newStrings is the same as the number of plots on
            % the associated axes object (e.g. if you have 2 lineseries and
            % 2 legend entries already no changes will be made).
            legtools.verchk()
            
            % Make sure lh exists and is a legend object
            if ~exist('lh', 'var') || ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:append:InvalidLegendHandle', ...
                      'Invalid legend handle provided' ...
                      );
            end
            
            % Pick first legend handle if more than one is passed
            if numel(lh) > 1
                warning('legtools:append:TooManyLegends', ...
                        '%u Legend objects specified, modifying the first one only', ...
                        numel(lh) ...
                        );
                lh = lh(1);
            end
            
            % Make sure newString exists & isn't empty
            if ~exist('newStrings', 'var') || isempty(newStrings)
                error('legtools:append:EmptyStringInput', ...
                      'No strings provided' ...
                      );
            end
            
            % Validate the input strings
            if ischar(newStrings)
                % Input string is a character array, assume it's a single
                % string and dump into a cell
                newStrings = {newStrings};
            end
            
            % Check shape of newStrings and make sure it's 1D
            if size(newStrings, 1) > 1
                newStrings = reshape(newStrings', 1, []);
            end
            
            % To make sure we target the right axes, pull the legend's
            % PlotChildren and get their parent axes object
            parentaxes = lh.PlotChildren(1).Parent;
            
            % Get line object handles
            plothandles = flipud(parentaxes.Children);  % Flip so order matches
            
            % Update legend with line object handles & new string array
            newlegendstr = [lh.String newStrings];  % Need to generate this before adding new plot objects
            lh.PlotChildren = plothandles;
            lh.String = newlegendstr;
        end
        
        
        function permute(lh, order)
            % PERMUTE rearranges the entries of the specified Legend
            % object, lh, so they are then the order specified by the
            % vector order. order must be the same length as the number of
            % legend entries in lh. All elements of order must be unique,
            % real, positive, integer values.
            legtools.verchk()
            
            % Make sure lh exists and is a legend object
            if ~exist('lh', 'var') || ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:permute:InvalidLegendHandle', ...
                      'Invalid legend handle provided' ...
                      );
            end
            
            % Pick first legend handle if more than one is passed
            if numel(lh) > 1
                warning('legtools:permute:TooManyLegends', ...
                        '%u Legend objects specified, modifying the first one only', ...
                        numel(lh) ...
                        );
                lh = lh(1);
            end
            
            % Catch length & uniqueness issues with order, let MATLAB deal
            % with the rest.
            if numel(order) ~= numel(lh.String)
                error('legtools:permute:TooManyIndices', ...
                      'Number of values in order must match the number of legend strings' ...
                      );
            end
            if numel(unique(order)) < numel(lh.String)
                error('legtools:permute:NotEnoughUniqueIndices', ...
                      'order must contain enough unique indices to index all legend strings' ...
                      );
            end
            
            % Permute the legend data source(s) and string(s)
            % MATLAB has a listener on the PlotChildren so when their order
            % is modified the string order is changed with it
            lh.PlotChildren = lh.PlotChildren(order);
        end
        
        
        function remove(lh, remidx)
            % REMOVE removes the legend entries of the Legend object, lh,
            % at the locations specified by remidx. All elements of remidx 
            % must be real, positive, integer values.
            % If remidx specifies all the legend entries the, Legend
            % object is deleted
            legtools.verchk()
            
            % Make sure lh exists and is a legend object
            if ~exist('lh', 'var') || ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:remove:InvalidLegendHandle', ...
                      'Invalid legend handle provided' ...
                      );
            end
            
            % Pick first legend handle if more than one is passed
            if numel(lh) > 1
                warning('legtools:remove:TooManyLegends', ...
                        '%u Legend objects specified, modifying the first one only', ...
                        numel(lh) ...
                        );
                lh = lh(1);
            end
            
            % Catch length issues, let MATLAB deal with the rest
            if numel(unique(remidx)) > numel(lh.String)
                error('legtools:remove:TooManyIndices', ...
                      'Number of unique values in remidx must match the number of legend entries' ...
                      );
            end
            
            if numel(unique(remidx)) == numel(lh.String)
                delete(lh);
                warning('legtools:remove:LegendDeleted', ...
                        'All legend entries specified for removal, deleting Legend Object' ...
                        );
            else
                lh.PlotChildren(remidx) = [];
            end
        end
    end
    
    methods (Static, Access = private)
        function verchk()
            % Throw error if we're not using R2014b or newer
            if verLessThan('matlab','8.4')
                error('legtools:UnsupportedMATLABver', ...
                      'MATLAB releases prior to R2014b are not supported' ...
                      );
            end
        end
    end
end