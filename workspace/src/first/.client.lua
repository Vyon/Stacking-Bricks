game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

repeat task.wait(.1) until game:IsLoaded()
script:Destroy()