include("../src/SpinMonteCarlo.jl")

using SpinMonteCarlo

const ups = [0,1,2]
const Ls = [8, 16, 24]
const Tc = 2.0/log1p(sqrt(2))
const Ts = Tc*linspace(0.85, 1.15, 11)
const MCS = 8192
const Therm = MCS >> 3

params = Dict{String, Any}[]
for update in ups
    for L in Ls
        for T in Ts
            push!(params,
                  Dict{String,Any}("Model"=>Ising, "Lattice"=>square_lattice,
                                   "L"=>L, "T"=>T,
                                   "MCS"=>MCS, "Thermalization"=>Therm,
                                   "UpdateMethod"=> (update==0 ? local_update! :
                                                     update==1 ? SW_update! : Wolff_update!),
                                   "update"=>update,
                                   "Verbose"=>true,
                                  ))
        end
    end
end

obs = map(runMC, params)

const pnames = ["update", "L", "T"]
const onames = ["Magnetization",
                "|Magnetization|",
                "Magnetization^2",
                "Magnetization^4",
                "Binder Ratio",
                "Susceptibility",
                "Connected Susceptibility",
                "Energy",
                "Energy^2",
                "Specific Heat",
                "MCS per Second",
                "Time per MCS",
               ]

const io = open("res-ising.dat", "w")
i=1
for pname in pnames
    println(io, "# \$$i : $pname")
    i+=1
end
for oname in onames
    println(io, "# \$$i, $(i+1): $oname")
    i+=2
end

for (p,o) in zip(params, obs)
    for pname in pnames
        print(io, p[pname], " ")
    end
    for oname in onames
        @printf(io, "%.15f %.15f ", mean(o[oname]), stderror(o[oname]))
    end
    println(io)
end

