import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';

class MediaLibraryScreen extends StatelessWidget {
  const MediaLibraryScreen({super.key});

  final List<String> _mediaAssets = const [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAaUCVojpKm1Wc4MmX-cV8EzPqlWdHO3Yv-DVNVoTaQFw_g5j_J1UWuVecaLkMvNJEMaLYyR4oBZXYAPEv1mIIQhd7AExxgDitJcOmLQQkYDcynB-ml8_hTwGVYVPzQENH_fOrvEovR3SDYqQAaYtzei_w0_bzBD_f6VA7aeyWg9aFDZFZtcYEjykLmozCW8HJogjULfsIvz-oJV8TH_r6Rpvo-GfGIebpcjY8NgPz_my0_-ooQ7vKs',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCUFM4qRqFC_TZJeKTQwQwXnyCV1oIE3FIsO9aSKabURyd4PrpOsRlw4xYZ2wmGEZJJwpfC0A8FQ7E9yGPPlX9eNzrQacQgghUEx_27dW1XcV0xijMvHdMAoZS_MLppRkDKsOk4BnW6szl_7KSGIBMaYRM4kxk_4mjJ1c7cbX1kDUR6E3GlCpd9qSv5IJ2hwgcRPMVWG1yiSdMJ-SO0nJIchRt7KLu8QDeqpaSIte_F--ngrO4IVYym',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCp0qgN3hBny3TPVFbO7gGAmejrSe3KwHRVeGQLZTMOODCvK8cHlFXLT4bRYOLIMt1aW0jvRSTpW_cChXB0qkmSIz24tAPXzcv7kmIaeQm7dCL5uUNLPAGDYRety9OFhKXnj2FaH3v7Ue2fGqA7NAc9gGpVufVvlpN77HV0H_QFC6Cm3zZyP9pdAF_SHEaEKZhLJDGalWB2Zn9QBt51e_lJaArk5vwQe08YtS-9dqcbnSH9c6_wHr3P',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAdNguKsbcgtZO-M6Iuy4uQdlUcn9NKKTY59IZcPCsOYikVNszPE_P_ud5kiX1B8mB7fjAcQar79qEQ6qShae-DAd2NXHPI2hmDSXIqwZ2K3w-5ZF7SMejF1zrPv4NhkvZJ9-r5d2lx6iFi5fjm85zl19M9osR86hcgHeKh252Mkqwdq_zE6qAfhJoj_e4gTMSKIebPSxKUYUhHF5N3Yl3dA055CtmBwcc4fHZ_5f4KRB-7gOlZWPjH',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDROe5ErrwF4brRLhwG3-qCpOK-nc_8RS-wpMH03HbpQanpDZeP1OjRK0B4aNkvGcmF6zYkMIgTMn8HsXOCuwle9yWztjOKlUdbwwJXo3SmUqY2VwwzrWuQW33TWlpGJvTXytC-OeRSHFkHfY3Z41uB_Fw38lio4qXcrPzplnvx26KDtZVi_cneILaxlnRT-XASXAvTNR9-IELbwesr5Rf4aPM0FHvnhNtaf0NWmXZT_smwVapZuJb-',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBgNaIqsvnXhSC2fmogcdeeT0-NR647lu-0_qqGa5zL8m4oy__7RCfyG9VDgXEOP4sdRz7BFYkk6w2P9LkIy_OkmnOrq0orHkSNDGZs8BfvhK1lypN5tuiMunezlG5vC7uX_DgZdLcCsTP4gZWw078mgUDULncBs9iHLwXOpxPAgDk2s5JWqMYwVzGQxowDPTjZLkHaYt8ReUwGYc6QHRFeGWWOk_jA4ACg8W6NHuKF4A6B7X5zM7EY',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MEDIA LIBRARY',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            NeoBrutalButton(
              label: '+ UPLOAD ASSET',
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: AppColors.primaryContainer,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.onSecondaryFixed,
                    content: Text(
                      'IMAGE UPLOADER PICKER OPENED',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _mediaAssets.length,
          itemBuilder: (context, index) {
            return NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(3, 3),
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                child: Image.network(
                  _mediaAssets[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(Icons.art_track, size: 32, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
