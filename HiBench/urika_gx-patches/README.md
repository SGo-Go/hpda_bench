# Patch for running HiBench on Cray Urika GX (Spark only)

- tested on the [Gilgamesh](https://kb.hlrs.de/platforms/index.php/Urika_GX) system at HLRS

## Installation

### 1st option: with `diff`

Applying the patch:
```{bash}
git clone https://github.com/Intel-bigdata/HiBench.git && cd ./HiBench
git checkout -b gilgamesh_branch aae754b
git apply ../gilgamesh-hibench/patch/gilgamesh-vanila-setup.diff
cp ../gilgamesh-hibench/patch/bin/* ./bin
```
Preparation of the patch:
```{bash}
module load tools/proxy
git clone https://github.com/Intel-bigdata/HiBench.git && cd ./HiBench

git rev-parse --short HEAD # returned aae754b
git diff > ../gilgamesh-hibench/patch/gilgamesh-vanila-setup.diff
cp ../patch/bin/* ./bin
```

### 2nd option: with `format-patch`

Applying the patch:
```{bash}
git clone https://github.com/Intel-bigdata/HiBench.git && cd ./HiBench
git checkout -b gilgamesh_branch aae754b
git apply --stat gilgamesh_complete_adoption.patch
git apply --check gilgamesh_complete_adoption.patch
git am --signoff < gilgamesh_complete_adoption.patch
```

Preparation of the patch (see details [here](https://www.devroom.io/2009/10/26/how-to-create-and-apply-a-patch-with-git/)):
```{bash}
module load tools/proxy
git clone https://github.com/Intel-bigdata/HiBench.git && cd ./HiBench/
git checkout -b gilgamesh_branch aae754b

git checkout -b fix_gilgamesh_branch
git add .
git commit -m "[HiBench] Gilgamesh adoptions"
git log --pretty=oneline -3
git format-patch gilgamesh_branch --stdout > gilgamesh_complete_adoption.patch
```

## Running

Example of run:
```{bash}
module load tools/mesos
./bin/run_bench_full.sh "huge large small tiny" "576 288 144 72 36"
```
