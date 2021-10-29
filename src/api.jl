##########################################################################################
# TODOs
##########################################################################################
# TODO: restore the infastructure of the previous GeoAxis where the axis grid is 
# curved and follows the projection used.
# TODO: create a function that can do surface plots for unstructured points
# (George has some script that does it lying around)

##########################################################################################
# GeoAxis implementation
##########################################################################################
"""
    GeoAxis(lons, lats, figloc; kwargs...)
Create a new axis instance that is based on `Axis`, but is appropriate for geospatial
plotting. `args...` is a standard figure location, e.g., `fig[1,1]` as given in
`Axis`. The keyword arguments decide the geospatial projection:

* `source = "+proj=longlat +datum=WGS84", dest = "+proj=wintri"`: These two keywords
configure the map projection to be used for the given field.
* `transformation = Proj4.Transformation(source, dest, always_xy=true)`: Instead of
  `source, dest` you can directly use the Proj4.jl package to define the projection.
* `coastlines = true`: Whether to plot coastlines.
* `coastkwargs = NamedTuple()` Keywords propagated to the coastline plot (which is a line plot).
"""
function GeoAxis(args...; 
        source = "+proj=longlat +datum=WGS84", dest = "+proj=wintri",
        transformation = Proj4.Transformation(source, dest, always_xy=true),
        coastlines = true, coastkwargs = NamedTuple(),
        kw... # Where is `kw` propagated into?
    )

    # Generate Axis instance
    ax = Axis(args...; aspect = DataAspect())
    # TODO:
    # ax = Axis(args...; interpolate_grid=true)
    # interpolate_grid would need to be implemented in the axis code, but that should be fairly straightforward 
    # needed to make the grid warp correctly

    # Set axis transformation
    ptrans = Makie.PointTrans{2}(transformation)
    ax.scene.transformation.transform_func[] = ptrans

    # set axis limits
    # TODO: I don't know how to set correct limits
    # points = [Point2f0(-171, -89), Point2f0(180, 90)]
    # rectLimits = FRect2D(transformation.(points)...) # This errors with Infinity
    # limits!(ax, rectLimits)
    lonslim = (-180, 180); latslim = (-90, 90)
    points = [Point2f0(lon, lat) for lon in lonslim, lat in latslim]
    rectLimits = FRect2D(Makie.apply_transform(ptrans, points))
    limits!(ax, rectLimits)

    # Plot coastlines
    coastlines && lines!(ax, GeoMakie.coastlines(), color = :black, overdraw = true, coastkwargs...)

    # Set ticks
    # TODO: Use latitude longitude that makes sense with given data
    # lonticks = range(lons[1], lons[end]; length = 4)
    # latticks = range(lats[1], lats[end]; length = 4)

    lonticks = -180:60:180
    latticks = -90:30:90
    xticks = first.(transformation.(Point2f0.(lonticks, latticks[1]))) 
    yticks = last.(transformation.(Point2f0.(lonticks[1], latticks)))
    ax.xticks = (xticks, string.(lonticks, 'ᵒ'))
    ax.yticks = (yticks, string.(latticks, 'ᵒ'))

    # TODO: Draw grid lines

    return ax
end
