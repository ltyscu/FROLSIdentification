%% Plots the all the GFRFs, one GFRF degree per plot. For degrees higher than 2, plots the number of specified slices of 
%   the GFRFs.
%
%   written by: Renato Naville Watanabe 
%
%
%   plotGFRF(GFRF, fmax, slices, unit, figureHeight, figureWidth, gapVertical, gapHorizontal, marginTop,...
%         marginBottom, marginLeft, marginRight)
%   
%   Inputs:
%
%   GFRF: cell, contains all GFRFs to be plotted.
%
%   fmax: float, maximal frequency to be plotted.
%
%   slices: integer, number of slices of the GFRFs with degree higher than two.
%
%   unit: string, length unit to be used. Possible units are 'pixels', 'normalized', 'inches', 
%   'centimeters', 'points' and 'characters'.
%
%   figureHeight: float, height of each plot, in the established unit.
%
%   figureWidth: float, width of each plot, in the established unit.
%
%   gapVertical: float, vertical gap between the plots, in the established unit.
%
%   gapHorizontal: float, horizontal gap between the plots, in the established unit.
%
%   marginTop: float, margin in the top of the figure, in the established unit.
%
%   marginBottom: float, margin in the bottom of the figure, in the established unit.
%
%   marginLeft: float, margin in the left side of the figure, in the established unit.
%
%   marginRight: float, margin in the right side of the figure, in the established unit.
%
%   freqAxisScaling: string, scale to be used in the frequency axis.
%   Possible strings are: 'linear' and 'log'.
%
%   GFRFAxisScaling: string, scale to be used in the GFRF axis.
%   Possible strings are: 'linear', 'db' and 'log'.



function plotGFRF(GFRF, fmax, slices, unit, figureHeight, figureWidth, gapVertical, gapHorizontal, marginTop,...
                marginBottom, marginLeft, marginRight, freqAxisScaling, GFRFAxisScaling)
    
    %% scale functions
    function scaledF = scaleFreq(f)
       if strcmp(freqAxisScaling, 'log')
           scaledF = log10(f);
       else
           scaledF = f;
       end       
    end

    function scaledGFRF = scaleGFRF(Hn)
       if strcmp(GFRFAxisScaling, 'log')
           scaledGFRF = log10(Hn);
       else if strcmp(GFRFAxisScaling, 'db')
                scaledGFRF = db(Hn);
           else
                scaledGFRF = Hn;
           end           
       end       
    end

    %% Octave verification
    V = ver;
    for i = 1:length(V)
        if (strcmp(V(i).Name,'Octave'))
            pkg load symbolic;
        end
    end
    
    %%
    numberOfGFRFs = length(GFRF);
    for i = 1:numberOfGFRFs
        if  logical(GFRF{i} ~= 0)
            Hfun = matlabFunction((abs(GFRF{i})));
            figure
            if nargin(Hfun) == 1
                ha = measuredPlot(1, 1, unit, figureHeight, figureWidth, gapVertical, gapHorizontal, marginTop, ...
                        marginBottom, marginLeft, marginRight);

                axes(ha(1));
                freq = [linspace(-fmax, 0, 50) linspace(0, fmax, 50)];
                plot(scaleFreq(freq), scaleGFRF(Hfun(freq)))
                xlabel('f (Hz)');
                ylabel('H_1')
                set(gca, 'Box','On', 'LineWidth', 2);
            else if nargin(Hfun) == 2                
                    ha = measuredPlot(1, 1, unit, figureHeight, figureWidth, gapVertical, gapHorizontal, marginTop, ...
                        marginBottom, marginLeft, marginRight + 1.9);
                    axes(ha(1));
                    freq1 = [linspace(-fmax, 0, 10) linspace(0, fmax, 10)];
                    freq2 = [linspace(-fmax, 0, 10) linspace(0, fmax, 10)];
                    [F1,F2] = meshgrid(freq1,freq2);
                    h = surf(scaleFreq(F1), scaleFreq(F2), scaleGFRF(Hfun(F1,F2))); title('');
                    set(h, 'EdgeColor', 'none', 'FaceColor','interp')
                    xlabel('f_1 (Hz)');
                    ylabel('f_2 (Hz)');
                    p = get(gca, 'Position');
                    c1 = colorbar('location', 'East', 'units','centimeters','Position',[p(1)+p(3)+1.3 p(2) 0.7 p(4)]);
                    axes(ha(end))
                    set(gca,'Position', p,'Box','On', 'LineWidth', 2);
                    axis([-fmax fmax -fmax fmax]);
                else
                    numberOfRows = ceil(sqrt(slices));
                    numberOfCols = ceil(sqrt(slices));                
                    ha = measuredPlot(numberOfRows, numberOfCols, unit, figureHeight, figureWidth, gapVertical, gapHorizontal, marginTop, ...
                        marginBottom, marginLeft, marginRight + 1.9);
                    fRes = nthroot(fmax * 2 / slices, nargin(Hfun) - 2);
                    f = -fmax:fRes:fmax;
                    for j = 0:length(ha)-1
                        axes(ha(j+1))
                        indices = dec2base(j, length(f), nargin(Hfun)-2);
                        fString = 'F1,F2';
                        titleString = '';
                        for k = 1:nargin(Hfun)-2
                            fString = strcat(fString, ',f(', num2str(base2dec(indices(k), length(f)) + 1), ')');
                            titleString = strcat(titleString, 'f_', num2str(k+2), '=', num2str(f(base2dec(indices(k), length(f)) + 1)), ',' );
                        end
                        titleString = titleString(1:end-1);
                        freq1 = [linspace(-fmax, 0, 20) linspace(0, fmax, 20)];
                        freq2 = [linspace(-fmax, 0, 20) linspace(0, fmax, 20)];
                        [F1,F2] = meshgrid(freq1,freq2);
                        eval(['h = surf(scaleFreq(F1), scaleFreq(F2), scaleGFRF(Hfun(' fString ')));']); 
                        set(h, 'EdgeColor', 'none', 'FaceColor','interp')
                        title(titleString, 'FontWeight', 'Bold');
                        if (mod(j+1,numberOfCols) == 1)
                            ylabel('f_2 (Hz)'); 
                        else
                            ylabel('');
                        end
                        if j+1 > (numberOfRows - 1) * numberOfCols
                            xlabel('f_1 (Hz)'); 
                        else
                            xlabel('')
                        end
                        p = get(gca, 'Position');
                        set(gca,'Position', p,'Box','On', 'LineWidth', 2);
                        axis([-fmax fmax -fmax fmax]);
                    end
                    c1 = colorbar('location', 'East', 'units','centimeters','Position',[p(1)+p(3)+1.3 p(2) 0.7 numberOfRows*p(4) + (numberOfRows-1) * gapVertical]);
                    axes(ha(end))
                    set(gca,'Position', p,'Box','On', 'LineWidth', 2);
                end
            end
        end
    end
end