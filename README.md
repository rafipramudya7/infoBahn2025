# Infoahn CTF 2025

berikut isi dari chaallange ini
## Infobahn Web Challange

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
    body {
        background: #0d1117;
        font-family: Arial, sans-serif;
        padding: 20px;
    }

    .gallery {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        justify-content: center;
    }

    /* FRAME BERUKURAN TETAP */
    .item {
        flex: 1 1 calc(25% - 15px);
        max-width: calc(25% - 15px);
        height: 260px;
        background: #161b22;
        border-radius: 10px;
        border: 2px solid #222;
        overflow: hidden;
        position: relative;
    }

    /* BOX UNTUK SCROLL */
    .scroll-box {
        width: 100%;
        height: 100%;
        overflow: hidden; /* default tidak scroll */
        cursor: pointer;
    }



    /* GAMBAR DI DALAM FRAME */
    .scroll-box img {
        width: 100%;
        display: block;
        transition: transform 0.2s ease;
    }

    /* Sedikit efek zoom saat hover */
    .item:hover img {
        transform: scale(1.03);
    }

    /* RESPONSIVE BREAKPOINTS */
    @media (max-width: 1024px) {
        .item {
            flex: 1 1 calc(33.33% - 15px);
            max-width: calc(33.33% - 15px);
        }
    }

    @media (max-width: 768px) {
        .item {
            flex: 1 1 calc(50% - 15px);
            max-width: calc(50% - 15px);
        }
    }

    @media (max-width: 480px) {
        .item {
            flex: 1 1 100%;
            max-width: 100%;
        }
    }


</style>
</head>
<body>


<div class="gallery">
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image1.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image2.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image3.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image4.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image5.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image6.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image7.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image8.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image9.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image10.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image11.png">
            </div>
        </a>
    </div>
    <div class="item">
        <a href="https://example.com" target="_blank">
            <div class="scroll-box">
                <img src="image12.png">
            </div>
        </a>
    </div>
</div>
</body>
</html>
