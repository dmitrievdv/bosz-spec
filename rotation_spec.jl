using GLMakie
using Korg

without_rot_spec = Korg.synth(; Teff=4000, logg=4, wavelengths=(6400,6700))
lambda = without_rot_spec[1]
flux = without_rot_spec[2]
cntm = without_rot_spec[3] # континуум

#исп makie
fig = Figure()
ax1 = Axis(fig[1,1],
    title = "star flux without rotation",
    xlabel = "wavelength",
    ylabel = "flux",
)
lines!(ax1, lambda, flux)

v_eq=15 #км/с
angle_i = pi/2
vsini = v_eq*sin(angle_i)

rot_flux = Korg.apply_rotation(flux, lambda, vsini)

ax2 = Axis(fig[2,1],
    title = "star flux with rotation",
    xlabel = "wavelength",
    ylabel = "flux",
)
lines!(ax2, lambda, rot_flux, color=:red )
display(fig)
