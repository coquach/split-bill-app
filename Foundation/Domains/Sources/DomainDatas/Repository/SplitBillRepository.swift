import Domains
import Foundation

public final class SplitBillRepository: ISplitBillRepository {
    private let client: SupabaseRestClient

    public init(client: SupabaseRestClient) {
        self.client = client
    }

    public func createSplitBill(
        _ command: CreateSplitBillCommand
    ) async throws -> SplitBill {
        do {
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [SplitBillDTO] = try await client.rpc(
                "create_split_bill",
                params: CreateSplitBillRequest(command)
            )

            guard let dto = rows.first else {
                throw DomainError.unknown(
                    code: "SPLIT_BILL_NOT_CREATED",
                    message: "Split Bill was not returned."
                )
            }

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
            let dtos: [SplitBillListItemDTO] = try await client.rpc(
                "get_split_bills",
                params: GetSplitBillsRequest(
                    role: role,
                    status: status,
                    page: page,
                    pageSize: pageSize
                )
            )

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
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [SplitBillDetailDTO] = try await client.rpc(
                "get_split_bill_detail",
                params: GetSplitBillDetailRequest(splitBillId: id)
            )

            guard let dto = rows.first else {
                throw DomainError.notFound
            }

            return dto.toDomain().splitBill
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getSplitBillDetail(
        id: UUID
    ) async throws -> SplitBillDetail {
        do {
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [SplitBillDetailDTO] = try await client.rpc(
                "get_split_bill_detail",
                params: GetSplitBillDetailRequest(splitBillId: id)
            )

            guard let dto = rows.first else {
                throw DomainError.notFound
            }

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func updateSplitBill(
        _ command: UpdateSplitBillCommand
    ) async throws -> SplitBill {
        do {
            let dto: SplitBillDTO = try await client.rpc(
                "update_split_bill",
                params: UpdateSplitBillRequest(command)
            )

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func closeSplitBill(id: UUID) async throws -> SplitBill {
        do {
            let dto: SplitBillDTO = try await client.rpc(
                "close_split_bill",
                params: CloseSplitBillRequest(splitBillId: id)
            )

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
