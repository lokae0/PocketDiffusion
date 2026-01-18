<img width="128" height="128" alt="" src="https://github.com/user-attachments/assets/7915bd13-539f-4d4f-bc0e-2f3f0a855dbf">
<img width="128" height="128" alt="" src="https://github.com/user-attachments/assets/76dd4974-d894-4c4b-9e20-535f0829b56c">
<p>

# Pocket Diffusion
This is a sample project that uses Stable Diffusion 1.5 to generate AI images locally on an iOS device. The app can be run fully offline and generated images are persisted.

**Demos:**
<!-- Thumbnails by https://t.cuts.so/github/video -->
| Editing settings, image generation, and cancellation | List editing, zoomable image view, copy settings |
| --- | --- |
| [<img width="400" src="https://github.com/user-attachments/assets/aa47c3e6-2d6b-4823-827f-0652c7f1c53c">](https://www.youtube.com/watch?v=r6OvNCVS0Kg) | [<img width="400" src="https://github.com/user-attachments/assets/3250afdb-e649-4043-9298-0d7ae59eaca2">](https://www.youtube.com/watch?v=cEn5hblZ5iE) |

**To run this project:** 
* Download the Stable Diffusion model files: [coreml-stable-diffusion-v1-5-palettized_split_einsum_v2_compiled.zip](https://huggingface.co/apple/coreml-stable-diffusion-v1-5-palettized/blob/main/coreml-stable-diffusion-v1-5-palettized_split_einsum_v2_compiled.zip)
* Unzip the folder and copy it into `/Resources`

**Topics covered:**
* Using Apple's [ml-stable-diffusion](https://github.com/apple/ml-stable-diffusion?tab=readme-ov-file#image-generation-with-swift) library to run local SD models with CoreML
  * The SD 1.5 variant specified above is quantized to fit within the lower RAM limits of a typical iOS device
  * `SPLIT_EINSUM_V2` allows the Apple Neural Engine (ANE) to be used alongside CPU for faster generations 
  * Although this model is outdated by 2026 standards, it suited this project well due to its ease of use, small size and fast speed. Plus, the hallucinations and artifacts are already becoming fun throwbacks! 😉
* Concurrency
  * Actor isolation and background threads for long running tasks (loading models, generating images, persistence, etc.)
  * Propagating `Task` cancellation across isolation boundaries, `AsyncStream`, and third party library tasks
  * Enabled strict concurrency for data race safety
  * Adapting to Swift 6.2's [Approachable Concurrency](https://github.com/swiftlang/swift-evolution/blob/main/visions/approachable-concurrency.md) default main actor isolation
* Basic persistence with `FileManager` and `UserDefaults`
  * Alternatives like [GRDB](https://github.com/groue/GRDB.swift), [sqlite-data](https://github.com/pointfreeco/sqlite-data), and SwiftData were considered but deemed overkill for the scope of this app  
* SwiftUI with Apple's Liquid Glass design
* String Catalogs (xcstrings) for localization
* Swift Testing
* Icon Composer

**License:**
* MIT. See the [LICENSE](https://github.com/lokae0/PocketDiffusion/blob/main/LICENSE.md) file for details.

**Acknowledgments:**
* `coreml-stable-diffusion-v1-5-palettized` model [details and license](https://huggingface.co/apple/coreml-stable-diffusion-v1-5-palettized)
* `ml-stable-diffusion` [license](https://github.com/apple/ml-stable-diffusion/blob/main/LICENSE.md)
