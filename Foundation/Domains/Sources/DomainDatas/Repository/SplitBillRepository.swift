import Domains
import Foundation
import Supabase

public final class SplitBillRepository: ISplitBillRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func createSplitBill(
        _ command: CreateSplitBillCommand
    ) async throws -> SplitBill {
        do {
            let dto: SplitBillDTO = try await client
                .rpc(
                    "create_split_bill",
                    params: CreateSplitBillRequest(command)
                )
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getSplitBills(
        role: SplitBillRoleFilter = .created,
        status: SplitBillStatusFilter = .all,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> SplitBillPage {
        do {
            let dtos: [SplitBillListItemDTO] = try await client
                .rpc(
                    "get_split_bills",
                    params: GetSplitBillsRequest(
                        role: role,
                        status: status,
                        page: page,
                        pageSize: pageSize
                    )
                )
                .execute()
                .value

            return SplitBillPage(
                items: dtos.map { $0.toDomain() },
                totalCount: dtos.first?.totalCount ?? 0,
                page: page,
                pageSize: pageSize
            )
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getSplitBill(id: UUID) async throws -> SplitBill {
        do {
            let dto: SplitBillDetailDTO = try await client
                .rpc(
                    "get_split_bill_detail",
                    params: GetSplitBillDetailRequest(splitBillId: id)
                )
                .execute()
                .value

            return dto.toDomain().splitBill
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getSplitBillDetail(
        id: UUID
    ) async throws -> SplitBillDetail {
        do {
            let dto: SplitBillDetailDTO = try await client
                .rpc(
                    "get_split_bill_detail",
                    params: GetSplitBillDetailRequest(splitBillId: id)
                )
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func updateSplitBill(
        _ command: UpdateSplitBillCommand
    ) async throws -> SplitBill {
        do {
            let dto: SplitBillDTO = try await client
                .rpc(
                    "update_split_bill",
                    params: UpdateSplitBillRequest(command)
                )
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func closeSplitBill(id: UUID) async throws -> SplitBill {
        do {
            let dto: SplitBillDTO = try await client
                .rpc(
                    "close_split_bill",
                    params: CloseSplitBillRequest(splitBillId: id)
                )
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
