Use master 
go

create database QuanLyNhaSach
go

use QuanLyNhaSach
go

--------
create table KhachHang
(
	MaKH int Not null,
	HoTen nvarchar(50) Not null,
	SDT nvarchar(11) Not null,
	DiaChi nvarchar(250) Not null,
	Email varchar(50) Not null
)
 alter table KhachHang add constraint pk_KhachHang primary key(MaKH)

 create table DonHang
 (
	MaDH int  Not null,
	MaKH int Not null,
	MaTT int null,
	MaNV int Not null, 
	NgayLapDH datetime Not null,
	DiaChiGH nvarchar(50) Not null,
	TrangThai nvarchar(50) Not null,
	GhiChu ntext null
 )
alter table DonHang add constraint pk_DonHang primary key (MaDH)


create table ChiTietDonHang 
( 
	MaDH int Not null,
	MaSach int Not null,
	SoLuongBan int Not null,
	GiaBan money Not null
)
alter table ChiTietDonHang add constraint pk_ChiTietDonHang primary key (MaDH, MaSach)

create table ThanhToan
(
	MaTT int Not null,
	NgayTT datetime Not null,
	SoTien money Not null,
	HinhThuc nvarchar(50) Not null,
	GhiChu ntext null
)
alter table ThanhToan add constraint pk_ThanhToan primary key (MaTT)

create table NhanVien
(
	MaNV int Not null,
	HoTenNV nvarchar(50) Not null,
	SDTNV varchar(11) Not null,
	DiaChiNV nvarchar(250) Not null,
	EmailNV varchar(50) Not null
)
alter table NhanVien add constraint pk_NhanVien primary key (MaNV)

create table Sach
(
	MaSach int Not null,
	MaLoai int Not null,
	TenSach nvarchar(50) Not null,
	MaNXB int Not null,
	SoLuongTon int Not null
)
alter table Sach add constraint pk_Sach primary key (MaSach)

create table LoaiSach
(
	MaLoai int Not null,
	TenLoai nvarchar(50) Not null
)
alter table LoaiSach add constraint pk_LoaiSach primary key (MaLoai)

create table NhaXuatBan
(
	MaNXB int Not null,
	TenNXB nvarchar(50) Not null,
	DiaChiNXB nvarchar(250) Not null,
	SDTNXB varchar(11) Not null
)
alter table NhaXuatBan add constraint pk_NhaXuatBan primary key (MaNXB)

create table PhieuNhap
(
	MaPN int Not null,
	MaNXB int Not null,
	NgayNhap datetime Not null
)
alter table PhieuNhap add constraint pk_PhieuNhap primary key (MaPN)

create table ChiTietPhieuNhap 
(
	MaSach int  Not null,
	MaPN int Not null,
	SoLuongNhap int Not null, 
	GiaNhap money Not null
)
alter table ChiTietPhieuNhap add constraint pk_ChiTietPhieuNhap primary key(MaSach, MaPN)


---DonHang
alter table DonHang add constraint fk_DonHang_KhachHang 
	foreign key (MaKH) references KhachHang(MaKH)
alter table DonHang add constraint fk_DonHang_ThanhToan
	foreign key (MaTT) references ThanhToan(MaTT)
alter table DonHang add constraint fk_DonHang_NhanVien
	foreign key (MaNV) references NhanVien(MaNV)
--ChiTietDonHang
alter table ChiTietDonHang add constraint fk_ChiTietDonHang_Sach
	foreign key (MaSach) references Sach(MaSach)
alter table ChiTietDonHang add constraint fk_ChiTietDonHang_DonHang 
	foreign key (MaDH) references DonHang(MaDH)

--Sach
alter table Sach add constraint fk_Sach_LoaiSach 
	foreign key (MaLoai) references LoaiSach(MaLoai)
alter table Sach add constraint fk_Sach_NhaXuatBan
	foreign key (MaNXB) references NhaXuatBan(MaNXB)

--PhieuNhapHang
alter table PhieuNhap add constraint fk_PhieuNhap_NhaXuatBan
	foreign key (MaNXB) references NhaXuatBan(MaNXB)

--ChiTiet_PhieuNhap
alter table ChiTietPhieuNhap add constraint fk_ChiTietPhieuNhap_Sach
	foreign key (MaSach) references Sach(MaSach)
alter table ChiTietPhieuNhap add constraint fk_ChiTietPhieuNhap_PhieuNhap
	foreign key (MaPN) references PhieuNhap(MaPN) 



--Kiểm tra số lượng bán
create trigger trg_SoLuongBan_GiaBan
on ChiTietDonHang
after insert, update
as
begin
	if exists (
		select 1
		from inserted
		where SoLuongBan <= 0)
	begin 
		raiserror (N'Nhập lại số lượng bán', 16, 1)
		rollback transaction
	end
	else
	if exists (
		select 1
		from inserted
		where GiaBan <= 0)
	begin 
		raiserror (N'Nhập lại giá bán', 16, 1)
		rollback transaction
	end 
end

-- Kiểm tra giá bán
create trigger trg_SoLuongNhap_GiaNhap
on ChiTietPhieuNhap
after insert, update
as
begin
	if exists (
		select 1
		from inserted
		where SoLuongNhap <= 0)
	begin 
		raiserror (N'Nhập lại số lượng nhập hàng', 16, 1)
		rollback transaction
	end
	else
	if exists (
		select 1
		from inserted
		where GiaNhap <= 0)
	begin 
		raiserror (N'Nhập lại giá nhập hàng', 16, 1)
		rollback transaction
	end 
end

-- Ngày lập hóa đơn
create trigger trg_NgayLapDH
on DonHang
after insert, update
as
begin
	if exists (
		select 1
		from inserted
		where NgayLapDH > getdate())
	begin 
		raiserror (N'Nhập lại ngày lập hóa đơn', 16, 1)
		rollback transaction
	end 
end

-- Ngày nhập hàng
create trigger trg_NgayNhap
on PhieuNhap
after insert, update
as
begin
	if exists (
		select 1
		from inserted
		where NgayNhap > getdate())
	begin 
		raiserror (N'Nhập lại ngày nhập hàng', 16, 1)
		rollback transaction
	end 
end

-- Ngày thanh toán
create trigger trg_NgayTT
on ThanhToan
after insert, update
as 
begin
	if exists (
		select 1 
		from ThanhToan TT
		join DonHang DH on TT.MaTT = DH.MaDH
		where TT.NgayTT < DH.NgayLapDH)
	begin
		raiserror (N'Ngày thanh toán phải cùng hoặc sau ngày lập đơn hàng', 16, 1)
		rollback transaction
	end 
end

-- Số lượng tồn kho
create trigger trg_SoLuongBan_SoLuongTon
on ChiTietDonHang
after insert, update
as 
begin
	if exists (
		select 1
		from inserted I
		join Sach S on I.MaSach = S.MaSach
		where I.SoLuongBan > S.SoLuongTon)
	begin
		raiserror (N'Số lượng tồn kho không đủ', 16, 1)
		rollback transaction
	end 
end

INSERT INTO KhachHang (MaKH, HoTen, SDT, DiaChi, Email)
VALUES ('002', 'Nguyen Van A', '0909123456', '123 Le Loi, Q.1, TP.HCM', 'nguyenvana@example.com');
INSERT INTO NhanVien (MaNV, HoTenNV, SDTNV, DiaChiNV, EmailNV)
VALUES ('1001', 'Tran Thi B', '0909234567', '456 Tran Hung Dao, Q.5, TP.HCM', 'tranthib@example.com');

INSERT INTO ThanhToan (MaTT, NgayTT, SoTien, HinhThuc)
VALUES ('3001', '2024-07-22', 500000, 'Tien Mat');
INSERT INTO LoaiSach (MaLoai, TenLoai)
VALUES ('4001', 'Van Hoc');


INSERT INTO NhaXuatBan (MaNXB, TenNXB, DiaChiNXB, SDTNXB)
VALUES ('7001', 'NXB Tre', '12 Nguyen Thi Minh Khai, Q.1, TP.HCM', '0909345678');


INSERT INTO DonHang (MaDH, MaKH, MaNV, MaTT, NgayLapDH, DiaChiGH, TrangThai, GhiChu)
VALUES ('2001', '001', '1001', '3001', '2024-07-22', '789 Nguyen Hue, Q.1, TP.HCM', 'Dang Xu Ly', 'Giao nhanh');

INSERT INTO Sach (MaSach, MaLoai, MaNXB, TenSach, SoLuongTon)
VALUES ('5003', '4001', '7001', '111', 100);
INSERT INTO ChiTietDonHang (MaDH, MaSach, SoLuongBan, GiaBan)
VALUES ('2001', '5003', 2, 0);
INSERT INTO PhieuNhap (MaPN, MaNXB, NgayNhap)
VALUES ('8001', '7001', '2024-07-21');
INSERT INTO ChiTietPhieuNhap (MaSach, MaPN, GiaNhap, SoLuongNhap)
VALUES ('5001', '8001', 200000, 50);