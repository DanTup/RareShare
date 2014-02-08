#r "System.IO.Compression"
#r "System.IO.Compression.FileSystem.dll"

open System
open System.IO
open System.IO.Compression


Directory.SetCurrentDirectory(__SOURCE_DIRECTORY__)
let addonFolder = Directory.GetCurrentDirectory()
// We need to create an extra level, because ZipFile.CreteFromDirectory doesn't include the directory,
// but we require it inside our zip (Curse requirement)
let tempReleaseFolderToZip = Path.Combine(addonFolder, "TempRelease")
let tempReleaseFolder = Path.Combine(tempReleaseFolderToZip, "RareShare")
let tocFile = "RareShare.toc"



let error s =
    printfn "\r\nERROR: %s\r\n\r\nPress any key...\r\n" s
    Console.ReadKey() |> ignore
    exit(1)



let run exe args =
    use p = new System.Diagnostics.Process()
    p.StartInfo.WorkingDirectory <- addonFolder
    p.StartInfo.FileName <- exe
    p.StartInfo.Arguments <- args
    p.StartInfo.UseShellExecute <- false
    p.StartInfo.RedirectStandardOutput <- true
    p.Start() |> ignore
    let output = p.StandardOutput.ReadToEnd()
    p.WaitForExit()
    output.Trim()



let get_version_from_toc() =
    File.ReadAllLines(tocFile) |>
    Array.find (fun l -> l.StartsWith("## Version: ")) |>
    fun l -> l.Replace("## Version: ", "")

let ensure_no_outstanding_changes() =
    let git = """C:\Users\Danny\AppData\Local\GitHub\PortableGit_fed20eba68b3e238e49a47cdfed0a45783d93651\bin\git.exe"""
    let statusOutput = run git "status -s"
    if statusOutput <> "" then
        error("Uncommitted changes!")

let create_temp_release_folder() =
    if Directory.Exists(tempReleaseFolder) then
        error("Temp release folder already exists!")
    Directory.CreateDirectory(tempReleaseFolder)

let delete_temp_release_folder() =
    if not <| Directory.Exists(tempReleaseFolderToZip) then
        error("Temp release folder does not exist!")
    Directory.Delete(tempReleaseFolderToZip, true)

let get_release_files() =
    let allFiles =
        addonFolder |>
        Directory.GetFiles |>
        Array.map (fun f -> FileInfo(f))
    let filteredFiles =
        allFiles |>
        Array.filter (fun f -> not <| f.Name.StartsWith("Test")) |>
        Array.filter (fun f -> f.Name <> "RareShareTests.lua") |>
        Array.filter (fun f -> f.Name <> "CreateRelease.fsx") |>
        Array.filter (fun f -> f.Name <> "RunTests.bat") |>
        Array.filter (fun f -> f.Name <> "RareShare.sln") |>
        Array.filter (fun f -> f.Name <> "RareShare.v12.suo")
    filteredFiles

let copy_to_temp_release_folder (files : FileInfo[]) =
    files |> Array.iter (fun f -> f.CopyTo(Path.Combine(tempReleaseFolder, f.Name)) |> ignore)



// Don't do anything if everything isn't committed
ensure_no_outstanding_changes()

// Figured out the version/filename from the TOC (this should be manually updated before building,
// since we don't know if the version should increase by 1, .1, etc)
let version = get_version_from_toc()
let releaseFile = Path.Combine(addonFolder, "Release_" + version + ".zip")

create_temp_release_folder()
get_release_files() |> copy_to_temp_release_folder
ZipFile.CreateFromDirectory(tempReleaseFolderToZip, releaseFile)
delete_temp_release_folder()

printfn ""
printfn "DONE!\r\n\r\nPress any key...\r\n"
Console.ReadKey() |> ignore
